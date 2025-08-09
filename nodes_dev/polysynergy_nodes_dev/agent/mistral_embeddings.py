from polysynergy_node_runner.setup_context.dock_property import dock_property
from polysynergy_node_runner.setup_context.node import Node
from polysynergy_node_runner.setup_context.node_decorator import node
from polysynergy_node_runner.setup_context.node_variable_settings import NodeVariableSettings
from polysynergy_node_runner.setup_context.path_settings import PathSettings
from polysynergy_nodes.agent.services.embeddings.mistral_embeddings import MistralEmbeddings as MistralEmbeddingsClient


@node(
    name="Embeddings Mistral",
    category="ai",
    icon="mistral_logo.svg"
)
class MistralEmbeddings(Node):

    model_name: str = NodeVariableSettings(
        label="Model Name",
        dock=dock_property(select_values={
            "mistral-embed": "mistral-embed",
        }),
        default="mistral-embed",
    )

    text: str = NodeVariableSettings(label="Text (singular)", has_in=True, info="If you just have one text to embed")
    texts: list = NodeVariableSettings(label="Texts (multiple)", has_in=True, info="If you have multiple texts to embed")

    api_key: str = NodeVariableSettings(
        label="API Key",
        has_in=True,
        dock=dock_property(
            enabled=False,
            info="Connect a secret (node) to set this value."
        ),
    )

    true_path: bool | list = PathSettings(label="Vector")
    false_path: bool | dict = PathSettings(label="Error")

    def execute(self):
        if not (self.texts and len(self.texts) > 0) and not (self.text and self.text.strip()):
            raise ValueError("No valid text provided for embedding")

        mistral_embedding_ai = MistralEmbeddingsClient(self.api_key, self.model_name)

        try:
            texts_to_embed = self.texts if self.texts else [self.text.strip()]
            result: list = mistral_embedding_ai.embed(texts_to_embed)
        except Exception as e:
            self.false_path = {'error': str(e)}
            return

        if not result or len(result) == 0:
            self.false_path = {'error': 'Failed to get embeddings from Mistral AI'}

        self.true_path = result
