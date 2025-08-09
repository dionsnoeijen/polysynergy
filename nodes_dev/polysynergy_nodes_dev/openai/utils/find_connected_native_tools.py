from polysynergy_node_runner.execution_context.is_compatible_provider import is_compatible_provider
from polysynergy_node_runner.setup_context.node import Node

from polysynergy_nodes.openai.services.native_tools.native_tool_base import NativeToolBase


def find_connected_native_tools(node: Node) -> NativeToolBase | None:
    native_tool_connections = [c for c in node.get_in_connections() if c.target_handle == "native_tools"]

    instances = []
    for conn in native_tool_connections:
        node = node.state.get_node_by_id(conn.source_node_id)
        if hasattr(node, "provide_instance") and is_compatible_provider(node, NativeToolBase):
            instances.append(node.provide_instance())

    return instances