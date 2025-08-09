from abc import ABC, abstractmethod
from typing import List, Dict, Optional


class ContextBase(ABC):
    def __init__(self, project_id: str, store_name: str):
        self.project_id = project_id
        self.store_name = store_name

    @abstractmethod
    def upsert_embeddings(
        self,
        items: List[Dict],
        vector_size: Optional[int] = None,
    ):
        pass

    @abstractmethod
    def query(
        self,
        query_vector: List[float],
        top_k: int = 5,
        filter_by: Optional[Dict[str, str]] = None,
    ):
        pass

    @abstractmethod
    def delete_collection(self):
        pass

    @abstractmethod
    def create_collection(
        self,
        vector_size: Optional[int] = None,
    ):
        pass