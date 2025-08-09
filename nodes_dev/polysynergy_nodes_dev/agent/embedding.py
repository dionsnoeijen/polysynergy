from polysynergy_nodes.agent.services.embeddings.embeddings_base import EmbeddingsBase
from polysynergy_nodes.agent.utils.find_connected_embeddings_client import find_connected_embeddings_client
from polysynergy_node_runner.setup_context.dock_property import dock_property
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.path_settings import PathSettings


@node(
    name="Embeddings",
    category="ai",
    icon="brain.svg",
)
class Embedding(Node):

    texts: list = NodeVariableSettings(
        label="Tests",
        has_in=True,
        required=True,
        dock=dock_property(
            info="The texts to be embedded",
        ),
    )

    client: EmbeddingsBase | None = NodeVariableSettings(
        label="Embedding Client",
        has_in=True,
    )

    true_path: bool | list = PathSettings(label="Embeddings")
    false_path: bool | dict = PathSettings(label="Error")

    def execute(self):
        if not self.texts or len(self.texts) == 0:
            raise ValueError("No valid text provided for embedding")

        self.client = find_connected_embeddings_client(self.id, self.flow)

        try:
            self.true_path = self.client.embed(self.texts)
        except Exception as e:
            raise RuntimeError(f"Embedding failed: {str(e)}")

