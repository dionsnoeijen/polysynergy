import os

from polysynergy_nodes.agent.services.contexts.context_base import ContextBase
from polysynergy_node_runner.setup_context.dock_property import dock_property
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.service_node import ServiceNode
from polysynergy_nodes.agent.services.contexts.qdrant_context_client import QdrantVectorClient


@node(
    name="Qdrant Client",
    category="ai",
    icon="qdrant_logo.svg"
)
class QdrantClient(ServiceNode):

    url: str = NodeVariableSettings(
        label="Qdrant URL",
        dock=True,
        required=True
    )

    store_name: str = NodeVariableSettings(
        label="Store Name",
        has_in=True,
        dock=True,
        required=True
    )

    api_key: str = NodeVariableSettings(
        label="API Key",
        dock=dock_property(
            enabled=False,
            info="Connect a secret (node) to set this value."
        ),
        has_in=True,
    )

    client: ContextBase | None = NodeVariableSettings(
        label="Qdrant Client",
        has_out=True
    )

    def provide_instance(self) -> ContextBase:
        self.client = QdrantVectorClient(
            self.url,
            self.api_key,
            os.getenv('PROJECT_ID'),
            self.store_name,
        )
        return self.client
