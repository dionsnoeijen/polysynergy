from polysynergy_nodes.agent.services.clients.client_base import ClientBase
from polysynergy_node_runner.setup_context.dock_property import dock_property
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.service_node import ServiceNode
from polysynergy_nodes.agent.services.clients.openai_client import OpenAIClient as OpenAIClientService

@node(
    name="OpenAI Client",
    category="ai",
    icon="openai_logo.svg",
)
class OpenAIClient(ServiceNode):

    model_name: str = NodeVariableSettings(
        label="Model Name",
        dock=dock_property(select_values={
            "gpt-3.5-turbo": "gpt-3.5-turbo",
            "gpt-4": "gpt-4",
        }),
        default="gpt-4",
    )

    temperature: float = NodeVariableSettings(
        label="Temperature",
        dock=True,
        default=0.7,
    )

    api_key: str = NodeVariableSettings(
        label="API Key",
        dock=dock_property(
            enabled=False,
            info="Connect a secret (node) to set this value."
        ),
        has_in=True,
    )

    client_service: ClientBase | None = NodeVariableSettings(
        label="Client Service",
        has_out=True,
    )

    def provide_instance(self) -> ClientBase:
        self.client_service = OpenAIClientService(
            model_name=self.model_name,
            api_key=self.api_key,
            temperature=self.temperature,
        )
        return self.client_service