import time

from qdrant_client import QdrantClient
from qdrant_client.http.models import (
    PointStruct, VectorParams, Distance, Filter, FieldCondition, MatchValue
)
from qdrant_client.http.exceptions import UnexpectedResponse
from typing import List, Dict, Optional
import uuid

from polysynergy_nodes.agent.services.contexts.context_base import ContextBase


class QdrantVectorClient(ContextBase):
    def __init__(
        self,
        url: str,
        api_key: str,
        project_id: str,
        store_name: str,
        default_vector_size: int = 1536
    ):
        self.client = QdrantClient(url=url, api_key=api_key)
        self.default_vector_size = default_vector_size
        self.project_id = project_id
        self.store_name = store_name
        self._collection_initialized: dict[str, bool] = {}

    @property
    def collection_name(self) -> str:
        return f"{self.project_id}_{self.store_name}"

    def collection_exists(self) -> bool:
        try:
            self.client.get_collection(self.collection_name)
            return True
        except UnexpectedResponse as e:
            msg = str(e).lower()
            if "doesn't exist" in msg or "not found" in msg:
                print(f"Collection '{self.collection_name}' does not exist.")
                return False
            print(f"Unexpected error while checking collection '{self.collection_name}': {e}")
            raise

    def _ensure_collection_once(self, vector_size: Optional[int] = None):
        print(f"Collection initialized? {self._collection_initialized.get(self.collection_name)}")
        if self._collection_initialized.get(self.collection_name):
            return

        vector_size = vector_size or self.default_vector_size

        if not self.collection_exists():
            print('Creating collection...')
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE)
            )

        self._collection_initialized[self.collection_name] = True

    def create_collection(self, vector_size: Optional[int] = None):
        vector_size = vector_size or self.default_vector_size
        self.client.recreate_collection(
            collection_name=self.collection_name,
            vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE),
        )
        self._collection_initialized[self.collection_name] = True

    def upsert_embeddings(self, items: list[dict], vector_size: Optional[int] = None):
        self._ensure_collection_once(vector_size)

        points = []
        for item in items:
            point_id = item.get("id")
            if isinstance(point_id, uuid.UUID):
                point_id = str(point_id)

            points.append(PointStruct(
                id=point_id,
                vector=item.get("vector"),
                payload=item.get("payload")
            ))

        self.client.upsert(collection_name=self.collection_name, points=points)

    def delete_collection(self):
        self.client.delete_collection(collection_name=self.collection_name)
        self._collection_initialized.pop(self.collection_name, None)

    def query(self, query_vector: List[float], top_k: int = 5, filter_by: Optional[Dict[str, str]] = None):
        filters = None
        if filter_by:
            filters = Filter(must=[
                FieldCondition(
                    key=k,
                    match=MatchValue(value=v)
                ) for k, v in filter_by.items()
            ])

        return self.client.query_points(
            collection_name=self.collection_name,
            query=query_vector,
            limit=top_k,
            with_payload=True,
            query_filter=filters
        )
