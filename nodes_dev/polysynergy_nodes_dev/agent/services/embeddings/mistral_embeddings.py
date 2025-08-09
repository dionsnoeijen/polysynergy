import time

from mistralai import Mistral

from polysynergy_nodes.agent.services.embeddings.embeddings_base import EmbeddingsBase


class MistralEmbeddings(EmbeddingsBase):
    def __init__(self, api_key: str, model_name: str = "mistral-embed"):
        if not api_key:
            raise ValueError("Mistral API-key is required.")
        self.client = Mistral(api_key=api_key)
        self.model = model_name

    def embed(self, texts: list[str]) -> list[list[float]]:
        time.sleep(1)
        response = self.client.embeddings.create(
            model=self.model,
            inputs=texts
        )
        return [embedding.embedding for embedding in response.data]