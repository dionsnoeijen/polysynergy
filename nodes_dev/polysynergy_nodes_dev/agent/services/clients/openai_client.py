import json

from openai import OpenAI

from polysynergy_nodes.agent.services.clients.client_base import ClientBase
from polysynergy_nodes.agent.services.embeddings.openai_embeddings import OpenAIEmbeddings


class OpenAIClient(ClientBase):

    def __init__(
        self,
        api_key: str,
        model_name: str = "gpt-4o",
        temperature: float = 0.7
    ):
        self.model_name = model_name
        self.model = OpenAI(
            api_key=api_key
        )
        self.embedding_client = OpenAIEmbeddings(
            api_key=api_key
        )
        self.temperature = temperature

    def embedding(self, prompt: str) -> list[list[float]]:
        return self.embedding_client.embed([prompt])

    def generate_response(
        self,
        messages: list[dict],
        template: str,
        max_tokens: int
    ) -> dict:

        print(json.dumps(messages, indent=2))
        print(json.dumps(template, indent=2))

        response_format = {
            "type": "json_schema",
            "json_schema": template,
        } if template else None

        response = self.model.chat.completions.create(
            model='gpt-4.1-2025-04-14',
            messages=messages,
            temperature=self.temperature,
            max_tokens=max_tokens,
            response_format=response_format,
        )

        print(response.choices[0].message)

        return json.loads(response.choices[0].message.content) \
            if response.choices else {}
