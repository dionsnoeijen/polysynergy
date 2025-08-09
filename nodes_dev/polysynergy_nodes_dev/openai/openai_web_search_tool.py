from typing import Literal, cast

from agents import WebSearchTool

from polysynergy_node_runner.setup_context.dock_property import dock_text_area, dock_dict, dock_property
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.service_node import ServiceNode
from polysynergy_nodes.openai.services.native_tools.native_tool_base import NativeToolBase


@node(
    name='OpenAi Web Search Tool',
    category='openai',
    icon='openai_dark.svg',
)
class OpenAiWebSearchTool(ServiceNode):

    city: str | None = NodeVariableSettings(
        label='City',
        info='Free text input for the city of the user, e.g. `San Francisco`.',
        dock=dock_text_area(rich=True),
    )

    country: str | None = NodeVariableSettings(
        label='Country',
        info='The two-letter [ISO country code](https://en.wikipedia.org/wiki/ISO_3166-1) of the user, e.g. `US`',
        dock=dock_text_area(rich=True),
    )

    region: str | None = NodeVariableSettings(
        label='Region',
        info='Free text input for the region of the user, e.g. `California`.',
        dock=dock_text_area(rich=True),
    )

    timezone: str | None = NodeVariableSettings(
        label='Timezone',
        info='The [IANA timezone](https://timeapi.io/documentation/iana-timezones) of the user, e.g. `America/Los_Angeles',
        dock=dock_text_area(rich=True),
    )

    search_context_size: str = NodeVariableSettings(
        label='Search Context Size',
        info='High level guidance for the amount of context window space to use for the search.',
        default='medium',
        dock=dock_property(select_values={
            'low': 'low',
            'medium': 'medium',
            'high': 'high',
        })
    )

    web_search_tool: NativeToolBase | None = NodeVariableSettings(
        label='Web Search Tool',
        has_out=True,
        dock=dock_dict(info='The web search tool instance.'),
    )

    def provide_instance(self) -> NativeToolBase:
        return WebSearchTool({
            'type': 'approximate',
            'city': self.city,
            'country': self.country,
            'region': self.region,
            'timezone': self.timezone,
        }, search_context_size=cast(
            Literal["low", "medium", "high"],
            self.search_context_size
        ))


