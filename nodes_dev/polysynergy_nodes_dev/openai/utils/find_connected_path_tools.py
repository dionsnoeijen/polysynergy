from uuid import uuid4

from agents import FunctionTool, FunctionToolResult, ToolCallOutputItem
import json

from openai.types.responses.response_input_item_param import FunctionCallOutput

from polysynergy_node_runner.execution_context.flow_state import FlowState
from polysynergy_node_runner.setup_context.node import Node

from polysynergy_node_runner.execution_context.utils.traversal import find_nodes_until


def find_nodes_for_tool(start_node):
    return find_nodes_until(
        start_node=start_node,
        match_end_node_fn=lambda node: node.__class__.__name__.lower().startswith("agenttoolresult"),
        get_node_by_id=start_node.state.get_node_by_id
    )


def create_tool_and_invoke(node: Node, tool_node, agent=None) -> FunctionTool:
    handle = tool_node.handle
    instructions = tool_node.instructions or "No description."
    arguments = tool_node.arguments or {}

    def set_agent(a):
        nonlocal agent
        agent = a

    schema = {
        "type": "object",
        "properties": {
            arg: {
                "type": "string",
                "description": desc.strip()
            } for arg, desc in arguments.items()
        },
        "required": list(arguments.keys()),
        "additionalProperties": False
    }

    tool = FunctionTool(
        name=handle,
        description=instructions,
        params_json_schema=schema,
        on_invoke_tool=None,  # added below
        strict_json_schema=True,
    )

    async def on_invoke(ctx, input_str: str, *, tool=tool, node_id=tool_node.id, handle=handle):
        print('INVOKING TOOL', handle, input_str)

        try:
            args = json.loads(input_str)
            start_node = node.state.get_node_by_id(node_id)

            for arg_name, value in args.items():
                start_node.arguments[arg_name] = value

            nodes_for_tool, end_node = find_nodes_for_tool(start_node)

            print('START_NODE', start_node)
            print('END_NODE', end_node)
            print('TOOL NODES', [n.handle for n in nodes_for_tool])

            if not start_node or not end_node:
                return f"Could not resolve tool subflow for {handle}"

            for node_for_tool in nodes_for_tool:
                node_for_tool.resurrect()

            start_node.flow_state = FlowState.ENABLED

            for connection in start_node.get_in_connections():
                start_node.add_found_by(connection.uuid)

            await node.flow.execute_node(start_node)

            start_node.flow_state = FlowState.PENDING

            print('RESULT', end_node.result)

            return FunctionToolResult(
                tool=tool,
                output=str(end_node.result),
                run_item=ToolCallOutputItem(
                    agent=agent,
                    raw_item=FunctionCallOutput(call_id=f'call_{uuid4().hex}', output=str(end_node.result), type='function_call_output'),
                    output=str(end_node.result),
                )
            )

        except Exception as e:
            print(f"[Error invoking tool {handle}]: {str(e)}")
            return f"[Error executing tool {handle}]: {str(e)}"

    tool.on_invoke_tool = on_invoke
    tool.set_agent = set_agent

    return tool


def find_connected_path_tools(node: Node) -> list[FunctionTool]:
    tool_connections = [
        c for c in node.get_out_connections()
        if c.source_handle == "path_tools"
    ]
    tools: list[FunctionTool] = []

    print('TOOLS', tools)

    for connection in tool_connections:
        tool_node = node.state.get_node_by_id(connection.target_node_id)

        if not type(tool_node).__name__.lower().startswith("openaitool"):
            continue

        tool = create_tool_and_invoke(node, tool_node)
        tools.append(tool)

    return tools