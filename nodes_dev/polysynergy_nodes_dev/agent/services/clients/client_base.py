from abc import ABC, abstractmethod

class ClientBase(ABC):
    @abstractmethod
    def generate_response(self, messages: list[dict], template: dict, max_tokens: int) -> dict:
        """
        Send a message to the client.
        """
        pass

    def embedding(self, prompt: str) -> list[list[float]]:
        """
        Get the embedding of a prompt.
        """
        pass