from polysynergy_nodes.agent.services.embeddings.embeddings_base import EmbeddingsBase
from polysynergy_node_runner.setup_context.dock_property import dock_property
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_nodes.agent.services.embeddings.openai_embeddings import OpenAIEmbeddings as OpenAIEmbeddingsClient
from polysynergy_node_runner.setup_context.service_node import ServiceNode

@node(
    name="OpenAI Embeddings Client",
    category="ai",
    icon="openai_logo.svg"
)
class OpenAIEmbeddingClient(ServiceNode):

    model_name: str = NodeVariableSettings(
        label="Model Name",
        dock=dock_property(select_values={
            "text-embedding-3-small": "text-embedding-3-small",
            "text-embedding-3-large": "text-embedding-3-large",
        }),
        default="text-embedding-3-small",
    )

    api_key: str = NodeVariableSettings(
        label="API Key",
        has_in=True,
        info="Connect a secret (node) to set this value."
    )

    embedding_service: EmbeddingsBase | None = NodeVariableSettings(
        label="Embedding Client",
        has_out=True,
    )

    def provide_instance(self) -> EmbeddingsBase:
        self.embedding_service = OpenAIEmbeddingsClient(
            api_key=self.api_key,
            model_name=self.model_name
        )
        return self.embedding_service