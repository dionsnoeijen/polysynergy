from concurrent.futures import ThreadPoolExecutor
import os
import time
import boto3
from polysynergy_nodes.agent.services.chat_memories.chat_memory_base import ChatMemoryBase

class DynamoDBChatMemoryService(ChatMemoryBase):

    def __init__(self, chat_id: str, storage_table: str, max_messages: int):

        is_lambda = os.getenv("AWS_EXECUTION_ENV") is not None

        if is_lambda:
            self.dynamodb = boto3.resource(
                "dynamodb",
                region_name=os.getenv("AWS_REGION", "eu-central-1"),
            )
        else:
            self.dynamodb = boto3.resource(
                "dynamodb",
                aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
                region_name=os.getenv("AWS_REGION", "eu-central-1"),
            )

        self.chat_id = chat_id
        self.table = self.get_table(os.getenv('PROJECT_ID') + "-" + storage_table)
        self.max_messages = max_messages
        self.executor = ThreadPoolExecutor(max_workers=3)  # Parallel writes

    def get_table(self, table_name):
        try:
            table = self.dynamodb.Table(table_name)
            table.load()
            return table
        except self.dynamodb.meta.client.exceptions.ResourceNotFoundException:
            return self.create_table(table_name)
        except Exception as e:
            print(f"⚠️ Fout bij ophalen van DynamoDB-tabel '{table_name}': {e}")
            raise

    def create_table(self, table_name):
        table = self.dynamodb.create_table(
            TableName=table_name,
            KeySchema=[
                {"AttributeName": "chat_id", "KeyType": "HASH"},
                {"AttributeName": "timestamp", "KeyType": "RANGE"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "chat_id", "AttributeType": "S"},
                {"AttributeName": "timestamp", "AttributeType": "N"}
            ],
            ProvisionedThroughput={"ReadCapacityUnits": 5, "WriteCapacityUnits": 5},
        )
        table.wait_until_exists()
        return table

    def save_message(self, role: str, content: str):
        timestamp = int(time.time() * 1000)
        def write_to_dynamodb():
            self.table.put_item(
                Item={
                    "chat_id": self.chat_id,
                    "timestamp": timestamp,
                    "role": role,
                    "content": content
                }
            )

        self.executor.submit(write_to_dynamodb)  # Schrijf asynchroon
        self.executor.submit(self._enforce_message_limit)  # Verwijderen asynchroon

    def _enforce_message_limit(self):
        response = self.table.query(
            KeyConditionExpression="chat_id = :chat_id",
            ExpressionAttributeValues={":chat_id": self.chat_id},
            Limit=self.max_messages + 10,
            ScanIndexForward=True
        )

        items = response.get("Items", [])
        excess = len(items) - self.max_messages
        if excess > 0:
            with self.table.batch_writer() as batch:
                for item in items[:excess]:
                    batch.delete_item(
                        Key={
                            "chat_id": item["chat_id"],
                            "timestamp": item["timestamp"]
                        }
                    )

    def save_messages_batch(self, messages: list):
        base_timestamp = int(time.time() * 1000)  # Basis timestamp
        timestamp_offset = 0

        with self.table.batch_writer() as batch:
            for message in messages:
                batch.put_item(
                    Item={
                        "chat_id": self.chat_id,
                        "timestamp": base_timestamp + timestamp_offset,  # Zorgt voor unieke timestamps
                        "role": message.get("role"),
                        "content": message.get("content")
                    }
                )
                timestamp_offset += 1

        self.executor.submit(self._enforce_message_limit)

    def get_last_messages(self):
        response = self.table.query(
            KeyConditionExpression="chat_id = :chat_id",
            ExpressionAttributeValues={":chat_id": self.chat_id},
            Limit=self.max_messages,
            ScanIndexForward=False
        )
        return response.get("Items", [])

    def __del__(self):
        self.executor.shutdown(wait=True)