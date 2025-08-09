import time
from polysynergy_nodes import openai

from polysynergy_nodes.agent.services.embeddings.embeddings_base import EmbeddingsBase

MAX_BATCH = 1000

class OpenAIEmbeddings(EmbeddingsBase):
    def __init__(self, api_key: str, model_name: str = "text-embedding-3-small"):
        if not api_key:
            raise ValueError("OpenAI API-key is required.")
        self.client = openai.OpenAI(api_key=api_key)
        self.model = model_name

    def embed(self, texts: list[str]) -> list[list[float]]:
        all_embeddings = []
        for i in range(0, len(texts), MAX_BATCH):
            batch = texts[i:i + MAX_BATCH]
            response = self.client.embeddings.create(
                model=self.model,
                input=batch
            )
            all_embeddings.extend([e.embedding for e in response.data])
            time.sleep(1)  # throttle als nodig
        return all_embeddings