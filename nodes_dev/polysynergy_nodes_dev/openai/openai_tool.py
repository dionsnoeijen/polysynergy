from polysynergy_node_runner.execution_context.flow_state import FlowState
from polysynergy_node_runner.setup_context.dock_property import dock_text_area, dock_dict
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.path_settings import PathSettings


@node(
    name='OpenAi Tool',
    category='openai',
    icon='openai_dark.svg',
    has_enabled_switch=False,
    flow_state=FlowState.PENDING,
)
class OpenAiTool(Node):
    agent: str = NodeVariableSettings(
        label="Agent",
        has_in=True
    )

    instructions: str = NodeVariableSettings(
        label='Instructions',
        info='Instructions for the OpenAI tool execution',
        dock=dock_text_area(rich=True),
    )

    arguments: dict = NodeVariableSettings(
        label="Arguments",
        dock=dock_dict(
            key_label="Argument name",
            value_label="Argument instructions",
            in_switch=False,
            out_switch_default=True
        ))

    true_path: bool = PathSettings(
        default=True,
        label='Continue',
        info='A way forward!',
    )

    def execute(self):
        # This node is a placeholder for OpenAI tool integration.
        # The actual implementation will depend on the specific OpenAI tool being used.
        pass