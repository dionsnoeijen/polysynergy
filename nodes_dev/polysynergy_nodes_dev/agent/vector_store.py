import os

from polysynergy_nodes.agent.services.contexts.context_base import ContextBase
from polysynergy_nodes.agent.services.contexts.qdrant_point import QdrantPoint
from polysynergy_nodes.agent.utils.find_connected_context import find_connected_context_client
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.path_settings import PathSettings

from pydantic import ValidationError

@node(
    name="Vector Store",
    category="ai",
    icon="brain.svg",
)
class VectorStore(Node):

    points: list = NodeVariableSettings(label="Point", has_in=True)

    context: ContextBase | None = NodeVariableSettings(label="Vector Client", has_in=True)

    true_path: bool = PathSettings(label="Success")
    false_path: bool | dict = PathSettings(label="Error")

    def execute(self):
        try:
            validated_points = [QdrantPoint(**p) for p in self.points]
        except ValidationError as e:
            self.false_path = {"error": "Invalid point(s)", "details": e.errors()}
            return

        storage_service = find_connected_context_client(self.id, self.flow)

        items = [point.dict() for point in validated_points]

        try:
            storage_service.upsert_embeddings(items)
        except Exception as e:
            self.false_path = {"error": f"Failed to store embeddings: {str(e)}"}
            return

        self.true_path = True
