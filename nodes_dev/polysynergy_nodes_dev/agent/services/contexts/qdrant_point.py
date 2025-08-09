from pydantic import BaseModel, Field
from typing import List, Dict, Any

class QdrantPoint(BaseModel):
    id: str
    vector: List[float]
    payload: Dict[str, Any]