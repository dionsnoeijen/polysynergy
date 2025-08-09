import json

from polysynergy_node_runner.setup_context.path_settings import PathSettings
from polysynergy_nodes.agent.services.chat_memories.chat_memory_base import ChatMemoryBase
from polysynergy_nodes.agent.services.clients.mistral_ai import MistralAI
from polysynergy_nodes.agent.utils.find_connected_tools import find_connected_tools
from polysynergy_nodes.agent.utils.find_connected_memory import find_connected_memory
from polysynergy_node_runner.setup_context.dock_property import dock_text_area
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings


@node(
    name='Mistral Agent',
    category='ai',
    icon='mistral_logo.svg',
)
class MistralAgent(Node):

    prompt: str = NodeVariableSettings(
        label="Value",
        default="{prompt.result_as_string}",
        dock=dock_text_area(
            info='This can be provided by the request, you can add a mock a prompt for testing.'
        ),
        has_in=True,
        required=True
    )
    instructions: str = NodeVariableSettings(label="Instructions", dock=dock_text_area(
        info='Please provide the necessary information to the agent. Like: how do you behave, what are you good at, etc. Be specific and clear.'
    ), has_in=True)
    context: str = NodeVariableSettings(label="Context", dock=dock_text_area(
        info='Additional background knowledge (RAG).'
    ), has_in=True)
    chat_memory: ChatMemoryBase | None = NodeVariableSettings(label="Chat Memory", dock=dock_text_area(
        info='Previous conversation history.'
    ), has_in=True)

    tools: str = NodeVariableSettings(label="Tools", has_out=True)

    true_path: bool | str = PathSettings(label="Answer")
    false_path: bool | dict = PathSettings(label="Error")

    def execute(self):
        mistral_agent = MistralAI('hfnFHCIGcEPN6cIKxH7z0BheRTgmQAsA')
        executable_tools = find_connected_tools(self.id, self.flow)
        chat_memory = find_connected_memory(self.id, self.flow)

        message_memory = [{"role": "system", "content": self.instructions}]

        if chat_memory is not None:
            self.chat_memory = chat_memory.provide_instance()
            memory = self.chat_memory.get_last_messages()
            message_memory.extend([
                {"role": msg["role"], "content": msg["content"]}
                for msg in memory
            ])

        message_memory.append({"role": "user", "content": self.prompt})

        try:
            result = mistral_agent.agent(
                message_memory=message_memory,
                executable_tools=executable_tools
            )
        except Exception as e:
            self.false_path = {"error": str(e)}
            return self

        if hasattr(result, "model_dump") and callable(result.model_dump):
            result_data = result.model_dump()
            if self.chat_memory is not None:
                self.chat_memory.save_messages_batch([
                    { 'role': 'user', 'content': self.prompt },
                    {
                        'role': 'system',
                        'content': result_data.get('message', {}).get('content', '')
                    }
                ])

        else:
            result_data = result

        self.true_path = json.dumps(result_data, indent=2)

        return self