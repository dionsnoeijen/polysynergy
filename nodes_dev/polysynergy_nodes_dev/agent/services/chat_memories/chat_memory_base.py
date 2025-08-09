from abc import ABC, abstractmethod

class ChatMemoryBase(ABC):
    @abstractmethod
    def save_message(self, role: str, message: str):
        pass

    @abstractmethod
    def get_last_messages(self):
        pass

    @abstractmethod
    def save_messages_batch(self, messages: list):
        pass