from polysynergy_node_runner.setup_context.node import Node

from polysynergy_nodes.agent.services.chat_memories.chat_memory_base import ChatMemoryBase
from polysynergy_node_runner.execution_context.is_compatible_provider import is_compatible_provider


def find_connected_memory(node: Node) -> ChatMemoryBase | None:
    memory_connections = [c for c in node.get_in_connections() if c.target_handle == "chat_memory"]

    for conn in memory_connections:
        node = node.state.get_node_by_id(conn.source_node_id)
        if hasattr(node, "provide_instance") and is_compatible_provider(node, ChatMemoryBase):
            return node.provide_instance()

    return None