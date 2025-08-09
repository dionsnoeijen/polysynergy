import json
from typing import Literal, Any

from agents import OpenAIResponsesModel, Agent, Runner, ModelSettings, RunConfig
from openai import AsyncOpenAI
from openai._types import Headers, Body, Query
from openai.types import Reasoning
from openai.types.responses import ResponseIncludable

from polysynergy_nodes.agent.services.chat_memories.chat_memory_base import ChatMemoryBase
from polysynergy_nodes.agent.services.contexts.context_base import ContextBase
from polysynergy_nodes.agent.utils.find_connected_context import find_connected_context_client
from polysynergy_nodes.agent.utils.find_connected_memory import find_connected_memory
from polysynergy_node_runner.setup_context.dock_property import dock_property, dock_text_area, dock_json
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_error import NodeError
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.path_settings import PathSettings
from polysynergy_nodes.openai.services.native_tools.native_tool_base import NativeToolBase
from polysynergy_nodes.openai.utils.find_connected_native_tools import find_connected_native_tools
from polysynergy_nodes.openai.utils.find_connected_path_tools import find_connected_path_tools
from polysynergy_nodes.openai.utils.output_schema import build_output_schema_from_json


@node(
    name="OpenAI Agent c",
    category="openai",
    icon="openai_dark.svg",
    metadata={ "layout": "openai_agent" }
)
class OpenAiAgent(Node):

    avatar: str = NodeVariableSettings(
        label="Avatar",
        dock=dock_property(metadata={"custom": "openai_avatar"}),
        metadata={"custom": "openai_avatar"},
    )

    name: str = NodeVariableSettings(
        label="Agent Name",
        default="OpenAI Agent",
        dock=True
    )

    instructions: str = NodeVariableSettings(
        label="Instructions",
        default="You are a helpful assistant.",
        has_in=True,
        dock=dock_text_area(rich=True),
        required=True
    )

    output_schema: str = NodeVariableSettings(
        label="Output Schema",
        dock=dock_json(),
    )

    secret: str | None = NodeVariableSettings(
        label="Secret Key",
        has_in=True,
        info="Use the secret key to fetch the OpenAI API key."
    )

    model: str | None = NodeVariableSettings(
        label="Model",
        has_in=True,
        default='gpt-4o',
        dock=dock_property(select_values={
            'gpt-4.1': 'gpt-4.1 (10.000 TPM)',
            'gpt-4.1-mini': 'gpt-4.1-mini (60.000 TPM)',
            'gpt-4.1-nano': 'gpt-4.1-nano (60.000 TPM)',
            'o3': 'o3 (100.000 TPM)',
            'o4-mini': 'o4-mini (100.000 TPM)',
            'gpt-4o': 'gpt-4o (10.000 TPM)',
            'gpt-4o-mini': 'gpt-4o-mini (60.000 TPM)',
        })
    )

    temperature: float | None = NodeVariableSettings(
        label="Temperature",
        group="Model Settings",
        dock=True,
        node=False,
        info="Temperature controls the randomness of the model's responses. Lower values make the output more deterministic, while higher values introduce more variability."
    )

    top_p: float | None = NodeVariableSettings(
        label="Top P",
        group="Model Settings",
        dock=True,
        node=False,
        info="Top P is a sampling technique that considers the cumulative probability of token choices."
    )

    frequency_penalty: float | None = NodeVariableSettings(
        label="Frequency Penalty",
        group="Model Settings",
        dock=True,
        node=False,
        info=(
            "Frequency penalty reduces the likelihood of the model repeating tokens "
            "that have already appeared in the conversation. A higher value discourages repetition."
        )
    )

    presence_penalty: float | None = NodeVariableSettings(
        label="Presence Penalty",
        group="Model Settings",
        dock=True,
        node=False,
        info=(
            "Presence penalty encourages the model to introduce new tokens that "
            "have not been used in the conversation. A higher value promotes diversity in responses."
        )
    )

    tool_choice: Literal["auto", "required", "none"] | str | None = NodeVariableSettings(
        label="Tool Choice",
        group="Model Settings",
        dock=True,
        node=False,
        info="Controls how the model selects tools: 'auto', 'required', or 'none'. You can also specify a custom tool name."
    )

    parallel_tool_calls: bool | None = NodeVariableSettings(
        label="Parallel Tool Calls",
        group="Model Settings",
        dock=True,
        node=False,
        info="Allow multiple tool calls in a single model turn. Set True to enable parallel calls or False to restrict to one."
    )

    truncation: Literal["auto", "disabled"] | None = NodeVariableSettings(
        label="Truncation Strategy",
        group="Model Settings",
        dock=True,
        node=False,
        info="Control how the model handles long inputs. 'auto' lets the model truncate as needed. 'disabled' disables truncation."
    )

    max_tokens: int | None = NodeVariableSettings(
        label="Max Tokens",
        group="Model Settings",
        dock=True,
        node=False,
        info="The maximum number of tokens the model is allowed to generate in its response."
    )

    reasoning: Reasoning | None = NodeVariableSettings(
        label="Reasoning Settings",
        group="Model Settings",
        dock=True,
        node=False,
        info="Advanced configuration for reasoning models (e.g., to enable intermediate steps or self-consistency)."
    )

    metadata: dict[str, str] | None = NodeVariableSettings(
        label="Metadata",
        group="Model Settings",
        dock=True,
        node=False,
        info="Custom metadata key-value pairs attached to the model request. Useful for logging or routing."
    )

    store: bool | None = NodeVariableSettings(
        label="Store Output",
        group="Model Settings",
        default=True,
        dock=True,
        node=False,
        info="Whether to store the response for future retrieval. True by default."
    )

    include_usage: bool | None = NodeVariableSettings(
        label="Include Usage Data",
        group="Model Settings",
        dock=True,
        node=False,
        info="Return token usage statistics with the response. Usually enabled for billing/debug purposes."
    )

    response_include: list[ResponseIncludable] | None = NodeVariableSettings(
        label="Response Includes",
        group="Model Settings",
        dock=True,
        node=False,
        info="Specify additional data to return in the response (e.g., search results, file metadata)."
    )

    extra_query: Query | None = NodeVariableSettings(
        label="Extra Query Params",
        group="Model Settings",
        dock=True,
        node=False,
        info="Additional query parameters to include in the model request URL."
    )

    extra_body: Body | None = NodeVariableSettings(
        label="Extra Body Fields",
        group="Model Settings",
        dock=True,
        node=False,
        info="Additional fields to include in the request body. Useful for provider-specific extensions."
    )

    extra_headers: Headers | None = NodeVariableSettings(
        label="Extra Headers",
        group="Model Settings",
        dock=True,
        node=False,
        info="Optional HTTP headers to send with the request, e.g., for debugging or routing."
    )

    extra_args: dict[str, Any] | None = NodeVariableSettings(
        label="Extra Args",
        group="Model Settings",
        dock=True,
        node=False,
        info="Catch-all for custom or experimental parameters not yet exposed in the SDK."
    )

    input: list | dict | str = NodeVariableSettings(
        label="Input",
        has_in=True,
        info="The input to the OpenAI agent. Can be a list, dict, or string."
    )

    native_tools: NativeToolBase | None = NodeVariableSettings(
        label='Native Tools',
        info='List of native OpenAI tools available for use',
        has_in=True,
    )


    rag_context: ContextBase | None = NodeVariableSettings(
        label="Context", dock=dock_text_area(
            info='Additional background knowledge (RAG).'
        ), has_in=True
    )

    chat_memory: ChatMemoryBase | None = NodeVariableSettings(
        label="Chat Memory",
        has_in=True
    )

    path_tools: str | None = NodeVariableSettings(
        label="Tools",
        has_out=True,
        default=[],
        info="Optional tools for the agent to use during execution."
    )

    true_path: str | None = PathSettings(
        label="Result",
        info="The result of the OpenAI agent execution."
    )

    false_path: str | dict | None = PathSettings(
        label="Error",
        info="Triggered if the OpenAI agent execution fails."
    )

    async def execute(self):
        try:
            chat_memory, client, context, model, native_tools, path_tools, run_config, schema = await self._setup()

            agent = Agent(
                model=model,
                name=self.name,
                instructions=self.instructions,
                tools=[t for group in (native_tools or [], path_tools or []) for t in group],
                output_type=schema,
                tool_use_behavior='run_llm_again'
            )

            for tool in path_tools:
                if hasattr(tool, "set_agent"):
                    print('SETTING AGENT WITH ', tool.name)
                    tool.set_agent(agent)

            messages = []
            if self.instructions:
                messages.append({"role": "system", "content": self.instructions})

            await self._build_memory(chat_memory, messages)
            latest_user_input = await self._add_user_input(messages)
            await self._add_context(client, context, latest_user_input, messages)

            print("TOOLS IN AGENT:")
            for t in agent.tools:
                print(" →", t.name)

            result = await Runner.run(agent, messages, run_config=run_config)
            self.true_path = result.final_output

            await self._store_history(chat_memory, messages, result)

        except Exception as e:
            self.false_path = NodeError.format(e)

    async def _setup(self):
        native_tools = find_connected_native_tools(self)
        path_tools = find_connected_path_tools(self)
        chat_memory = find_connected_memory(self)
        context = find_connected_context_client(self)
        model_settings = ModelSettings(
            temperature=self.temperature,
            top_p=self.top_p,
            frequency_penalty=self.frequency_penalty,
            presence_penalty=self.presence_penalty
        )
        client = AsyncOpenAI(api_key=self.secret)
        model = OpenAIResponsesModel(model=self.model, openai_client=client)
        run_config = RunConfig(model=model, model_settings=model_settings)
        schema = await self._build_schema()
        return chat_memory, client, context, model, native_tools, path_tools, run_config, schema

    async def _store_history(self, chat_memory, messages, result):
        if chat_memory:
            for msg in messages:
                chat_memory.save_message(msg["role"], msg["content"])
            if result and result.final_output:
                value = (
                    result.final_output.get("answer", str(result.final_output))
                    if isinstance(result.final_output, dict)
                    else str(result.final_output)
                )
                chat_memory.save_message("assistant", value)

    async def _add_context(self, client, context, latest_user_input, messages):
        if context and latest_user_input:
            embedding_response = await client.embeddings.create(
                input=latest_user_input,
                model="text-embedding-3-small"
            )
            embedding = embedding_response.data[0].embedding
            results = context.query(embedding)
            payloads = []

            for point in results.points:
                payload = getattr(point, 'payload', None)
                id = getattr(point, 'id', None)
                if payload:
                    payload['id'] = id
                    payloads.append(payload)

            if payloads:
                json_context = json.dumps(payloads, indent=2)
                messages.insert(1, {
                    "role": "system",
                    "content": f"Use the following data when answering the user:\n{json_context}"
                })

    async def _add_user_input(self, messages):
        if isinstance(self.input, str):
            messages.append({"role": "user", "content": self.input})
        elif isinstance(self.input, dict):
            messages.append(self.input)
        elif isinstance(self.input, list):
            messages.extend(self.input)
        else:
            raise ValueError("Invalid input format. Must be string, dict, or list.")
        # Context (RAG)
        latest_user_input = next(
            (m["content"] for m in reversed(messages)
             if m["role"] == "user" and isinstance(m.get("content"), str)),
            None
        )
        return latest_user_input

    async def _build_memory(self, chat_memory, messages):
        if chat_memory:
            history = chat_memory.get_last_messages()
            for item in reversed(history):
                messages.append({"role": item["role"], "content": item["content"]})

    async def _build_schema(self):
        try:
            if not self.output_schema:
                return None
            output_schema_json = json.loads(self.output_schema)
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON in output_schema: {e.msg}")
        return build_output_schema_from_json(output_schema_json)