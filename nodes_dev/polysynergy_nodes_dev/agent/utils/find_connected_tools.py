from polysynergy_node_runner.execution_context.flow import Flow

def generate_tools_schema(tools: dict) -> dict:
    schema = {
        "type": "object",
        "properties": {
            "answer": {
                "type": "string",
                "description": "Default answer in the user's language."
            }
        },
        "required": ["answer"],
        "additionalProperties": False
    }

    for tool_name, tool_data in tools.items():
        schema["properties"][tool_name] = {
            "type": "object",
            "properties": {
                arg: {
                    "type": "string",
                    "description": desc.strip()
                }
                for arg, desc in tool_data.get("arguments", {}).items()
            },
            "required": list(tool_data.get("arguments", {}).keys()),
            "additionalProperties": False
        }

    return {
        "name": "default_response",
        "schema": schema,
        "strict": True
    }

def format_tool_instructions(tools: dict) -> str:
    output = [
        "You can call tools when an action is required. Each tool must be used exactly as defined.\n\nAvailable tools:"]
    for name, info in tools.items():
        purpose = info.get("instructions", "No description provided.").strip()
        args = info.get("arguments", {})
        arg_lines = []
        for arg, desc in args.items():
            arg_lines.append(f"- `{arg}` *(string)* – {desc.strip()}")
        args_text = "\n".join(arg_lines) if arg_lines else "None"
        tool_block = f"""\
### Tool: `{name}`  
**Purpose:** {purpose}  
**Required arguments:**  
{args_text}  

Use this tool when appropriate. Always provide the required arguments.\
"""
        output.append(tool_block)
    return "\n\n".join(output)

def find_connected_tools(node_id: str, flow: Flow) -> dict:
    tool_connections = [c for c in flow.get_out_connections(node_id) if c.source_handle == "tools"]
    executable_tools: dict = {}

    if tool_connections:
        target_tool_ids = [c.target_node_id for c in tool_connections]

        for tool_id in target_tool_ids:
            tool = flow.nodes[tool_id]

            if type(tool).__name__ == "AgentTool":
                executable_tools[tool.handle] = {
                    "id": tool.id,
                    "instructions": tool.instructions,
                    "arguments": tool.arguments
                }
            else:
                print(f"Invalid tool ignored: {tool_id} (geen AgentTool)")

    return executable_tools
