from polysynergy_node_runner.setup_context.dock_property import dock_property
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.service_node import ServiceNode
from polysynergy_nodes.agent.services.chat_memories.dynamo_db_chat_memory import DynamoDBChatMemoryService
from polysynergy_nodes.agent.services.chat_memories.chat_memory_base import ChatMemoryBase


@node(
    name="Chat Memory",
    category="ai",
    has_enabled_switch=False,
    icon="brain.svg"
)
class ChatMemory(ServiceNode):
    chat_id: str = NodeVariableSettings(
        label="Chat ID",
        dock=dock_property(
            info="Unique identifier for the chat session. This is used to store and retrieve messages from the database."
        ),
    )

    max_messages: int = NodeVariableSettings(
        label="Max Messages",
        dock=True,
        default=100
    )

    storage_table: str = NodeVariableSettings(
        label="Storage Table",
        dock=True,
        default="chat_memory"
    )

    chat_memory_service: ChatMemoryBase | None = NodeVariableSettings(
        label="Chat Memory Service",
        has_out=True
    )

    def provide_instance(self) -> ChatMemoryBase:
        self.chat_memory_service = DynamoDBChatMemoryService(
            self.chat_id,
            self.storage_table,
            self.max_messages
        )
        return self.chat_memory_service
