from agents import AgentOutputSchema
from types import new_class
from typing_extensions import TypedDict

def build_output_schema_from_json(json_schema: dict) -> AgentOutputSchema:
    name = json_schema.get("name", "DynamicOutput")
    props = json_schema.get("properties", {})
    required = set(json_schema.get("required", []))

    required_fields = {
        key: map_json_type_to_python(value["type"])
        for key, value in props.items()
        if key in required
    }

    optional_fields = {
        key: map_json_type_to_python(value["type"])
        for key, value in props.items()
        if key not in required
    }

    namespace = {"__annotations__": {}}
    namespace["__annotations__"].update(required_fields)
    namespace["__annotations__"].update(optional_fields)
    namespace["__total__"] = True

    output_type = new_class(name, (TypedDict,), {}, lambda ns: ns.update(namespace))

    return AgentOutputSchema(output_type)

def map_json_type_to_python(json_type: str) -> type:
    match json_type:
        case "string":
            return str
        case "number":
            return float
        case "integer":
            return int
        case "boolean":
            return bool
        case "array":
            return list
        case "object":
            return dict
        case _:
            raise ValueError(f"Unsupported JSON type: {json_type}")