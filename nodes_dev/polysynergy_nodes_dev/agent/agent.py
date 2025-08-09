# PACKAGE RECOMMENDATION: Move to @polysynergy/ai-agents
# This node provides complex AI agent orchestration with external dependencies (OpenAI, Mistral, Qdrant).
# It would be better suited in a dedicated AI/ML package rather than core basic nodes.

import json
from polysynergy_node_runner.execution_context.flow_state import FlowState
from polysynergy_node_runner.setup_context.path_settings import PathSettings
from polysynergy_node_runner.setup_context.dock_property import dock_text_area, dock_json
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings

from polysynergy_nodes.agent.services.clients.client_base import ClientBase
from polysynergy_nodes.agent.services.contexts.context_base import ContextBase
from polysynergy_nodes.agent.utils.find_connected_client import find_connected_client
from polysynergy_nodes.agent.utils.find_connected_context import find_connected_context_client
from polysynergy_nodes.agent.utils.find_connected_tools import find_connected_tools, format_tool_instructions
from polysynergy_nodes.agent.utils.find_connected_memory import find_connected_memory
from polysynergy_nodes.agent.services.chat_memories.chat_memory_base import ChatMemoryBase

@node(
    name='Agent',
    category='ai',
    icon='brain.svg',
)
class Agent(Node):
    prompt: str = NodeVariableSettings(
        label="Prompt",
        default="",
        dock=dock_text_area(info='Provide a prompt.'),
        has_in=True,
        required=True
    )

    instructions: str = NodeVariableSettings(label="Instructions", dock=dock_text_area(
        rich=True,
        info='Please provide the necessary information to the agent. Like: how do you behave, what are you good at, etc. Be specific and clear.'
    ), has_in=True)

    DEFAULT_AGENT_SCHEMA = '''{
    "name": "default_response",
    "schema": {
        "type": "object",
        "properties": {
            "answer": {
                "type": "string",
                "description": "Default answer in the language of the prompt of the user."
            }
        },
        "required": [
            "answer"
        ],
        "additionalProperties": false
    }
}'''

    structured_output: str | list | dict = NodeVariableSettings(
        label="Structured Output Template",
        has_in=True,
        default=DEFAULT_AGENT_SCHEMA,
        dock=dock_json(info="Use a template to define the structure of the expected AI output."),
    )

    max_tokens: int = NodeVariableSettings(
        label="Max Tokens",
        default=1500,
        dock=dock_text_area(info="Maximum tokens for the model response."),
        has_in=True
    )

    context: ContextBase | None = NodeVariableSettings(
        label="Context", dock=dock_text_area(
        info='Additional background knowledge (RAG).'
    ), has_in=True)

    chat_memory: ChatMemoryBase | None = NodeVariableSettings(label="Chat Memory", has_in=True)

    client: ClientBase | None = NodeVariableSettings(label="Client", dock=dock_text_area(
        info='Client information.'
    ), has_in=True)

    tools: str = NodeVariableSettings(label="Tools", has_out=True)

    true_path: bool | str | dict = PathSettings(label="Answer")
    false_path: bool | dict = PathSettings(label="Error")

    def _find_nodes_for_tool(self, start_node):
        return start_node._find_nodes_until(
            match_end_node_fn=lambda node: node.__class__.__name__ == "AgentToolResult"
        )

    def _call_tool(self, tool_name, arguments):
        start_node = self.flow.get_node(tool_name)
        nodes_for_tool, end_node = self._find_nodes_for_tool(start_node)

        if not nodes_for_tool:
            raise ValueError(f"No nodes found for tool: {tool_name}")

        if not start_node:
            raise ValueError(f"Tool node not found: {tool_name}")

        for node_for_tool in nodes_for_tool:
            node_for_tool.resurrect()

        start_node.flow_state = FlowState.ENABLED

        in_connections = start_node.get_in_connections()
        for connection in in_connections:
            start_node.add_found_by(connection.uuid)

        self.flow.execute_node(start_node)

        start_node.flow_state = FlowState.PENDING

        return end_node.result

    def _run_agent_loop(self, messages, client, template, tools_dict, max_tokens=1500):
        while True:
            output = client.generate_response(messages, template, max_tokens)

            answer = output.get("answer", "")

            tool_calls = {
                key: val for key, val in output.items()
                if key in tools_dict and isinstance(val, dict) and val
            }

            if not tool_calls:
                return output

            tool_outputs = []
            for tool_name, arguments in tool_calls.items():
                result = self._call_tool(tool_name, arguments)
                tool_outputs.append({
                    "role": "system",
                    "content": f"Result from tool '{tool_name}': {json.dumps(result)}"
                })

            messages.append({"role": "assistant", "content": answer})
            messages.extend(tool_outputs)
            messages.append({"role": "user", "content": "Please continue."})


    def execute(self):
        if not self.prompt:
            self.false_path = {"error": "Prompt is empty."}
            return None

        client = find_connected_client(self.id, self.flow)
        chat_memory = find_connected_memory(self.id, self.flow)
        context = find_connected_context_client(self.id, self.flow)
        tools = find_connected_tools(self.id, self.flow)

        if isinstance(self.structured_output, str):
            try:
                template = json.loads(self.structured_output)
            except json.JSONDecodeError as e:
                self.false_path = {"error": f"Invalid JSON in structured_output: {str(e)}"}
                return
        else:
            template = self.structured_output

        history = []
        if chat_memory:
            items = chat_memory.get_last_messages()
            for item in reversed(items):
                history.append({"role": item["role"], "content": item["content"]})

        messages = []
        if self.instructions:
            messages.append({"role": "system", "content": self.instructions})

        if tools:
            tools_prompt = format_tool_instructions(tools)
            for tool_name, tool_data in tools.items():
                template['schema']['properties'][tool_name] = {
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
            messages.append({"role": "system", "content": tools_prompt})

        if context:
            embedding = client.embedding(self.prompt)
            results = context.query(embedding[0])
            payloads = []

            for point in results.points:
                payload = getattr(point, 'payload', None)
                id = getattr(point, 'id', None)
                if payload:
                    payload['id'] = id
                    payloads.append(payload)

            if payloads:
                json_context = json.dumps(payloads, indent=2)
                messages.append({
                    "role": "system",
                    "content": f"Use the following data when answering the user:\n{json_context}"
                })

        messages.extend(history)
        messages.append({"role": "user", "content": self.prompt})

        # out = client.generate_response(messages, template, self.max_tokens)
        out = self._run_agent_loop(
            messages,
            client,
            template,
            tools,
            self.max_tokens
        )

        if chat_memory:
            chat_memory.save_message("user", self.prompt)
            chat_memory.save_message("assistant", out.get("answer", ""))

        self.true_path = out
