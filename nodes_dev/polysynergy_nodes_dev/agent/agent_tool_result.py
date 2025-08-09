from polysynergy_node_runner.setup_context.dock_property import dock_text_area, dock_dict
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings

@node(
    name="Tool Result",
    category="ai",
    icon="hammer.svg"
)
class AgentToolResult(Node):

    result: dict = NodeVariableSettings(
        label="Result",
        info="The result of the tool execution",
        dock=dock_dict(
            key_label="Argument Name",
            value_label="Tool Result",
            out_switch=False,
            in_switch_default=True,
            in_switch=False
        ),
        has_in=True
    )

    def execute(self):
        pass
