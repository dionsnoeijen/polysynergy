from mistralai import Mistral

class MistralAI:
    def __init__(self, api_key: str):
        if not api_key:
            raise ValueError("Mistral API-key is required.")

        self.client = Mistral(api_key=api_key)
        self.model = "mistral-large-latest"

    @staticmethod
    def _convert_to_tools_structure(input_data: dict) -> list:
        tools = []

        for tool_name, tool_data in input_data.items():
            tool = {
                "type": "function",
                "function": {
                    "name": tool_name,
                    "description": tool_data.get("instructions", "No description provided"),
                    "parameters": {
                        "type": "object",
                        "properties": {},
                        "required": list(tool_data["arguments"].keys())
                    }
                }
            }

            for arg_name, arg_desc in tool_data["arguments"].items():
                tool["function"]["parameters"]["properties"][arg_name] = {
                    "type": "string",
                    "description": arg_desc
                }

            tools.append(tool)

        return tools

    def agent(
        self,
        message_memory: list = None,
        executable_tools: dict = None
    ):
        tools = self._convert_to_tools_structure(executable_tools) if executable_tools else []

        try:
            model = "mistral-large-latest"
            response = self.client.chat.complete(
                model=model,
                messages=message_memory,
                tools=tools,
                tool_choice="auto",
            )
            return response.choices[0]
        except Exception as e:
            return f"Fout bij communiceren met Mistral API: {str(e)}"