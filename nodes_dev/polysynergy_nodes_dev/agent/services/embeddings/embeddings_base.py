from abc import ABC, abstractmethod

class EmbeddingsBase(ABC):
    @abstractmethod
    def embed(self, texts: list[str]) -> list[list[float]]:
        pass
