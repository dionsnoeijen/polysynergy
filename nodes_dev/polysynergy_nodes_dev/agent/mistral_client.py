from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.service_node import ServiceNode

@node(
    name="Mistral Client",
    category="ai",
    has_enabled_switch=False,
    icon="mistral.svg"
)
class MistralClient(ServiceNode):
    def provide_instance(self):
        from polysynergy_nodes.agent.services.mistral_client import MistralClientService
        return MistralClientService()
