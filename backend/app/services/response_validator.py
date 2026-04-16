import re
from typing import Any

from pydantic import TypeAdapter

from app.schemas import AnalyzeBirdResponse

analyze_adapter = TypeAdapter(AnalyzeBirdResponse)


def _normalize_string(value: str) -> str:
    normalized = re.sub(r"\s+", " ", value.strip())
    if not normalized:
        raise ValueError("empty string after normalization")
    return normalized


def _normalize_data(obj: Any) -> Any:
    if isinstance(obj, str):
        return _normalize_string(obj)
    if isinstance(obj, list):
        return [_normalize_data(item) for item in obj]
    if isinstance(obj, dict):
        return {key: _normalize_data(value) for key, value in obj.items()}
    return obj


def validate_analyze_payload(payload: dict) -> dict:
    normalized = _normalize_data(payload)
    validated = analyze_adapter.validate_python(normalized)
    return analyze_adapter.dump_python(validated)


def analyze_json_schema() -> dict:
    # OpenAI Structured Outputs requires the top-level schema to be type "object".
    # The plain JSON schema generated from a Union can be top-level anyOf/oneOf,
    # which is rejected by the API.
    return {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "success": {"type": "boolean", "const": True},
            "result_type": {"type": "string", "enum": ["bird_identified", "image_unusable"]},
            "bird": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "common_name": {"type": "string", "minLength": 1, "maxLength": 120},
                    "scientific_name": {"type": "string", "minLength": 1, "maxLength": 160},
                    "confidence_label": {
                        "type": "string",
                        "enum": [
                            "quasi certain",
                            "fort probable",
                            "probable",
                            "incertain",
                            "hautement incertain",
                        ],
                    },
                    "discovery_level": {"type": "integer", "minimum": 1, "maximum": 6},
                    "fun_type_label": {"type": "string", "minLength": 1, "maxLength": 40},
                    "habitat_short": {"type": "string", "minLength": 1, "maxLength": 160},
                    "diet_short": {"type": "string", "minLength": 1, "maxLength": 160},
                    "professor_commentary_text": {"type": "string", "minLength": 1, "maxLength": 700},
                    "alternatives": {
                        "type": "array",
                        "minItems": 3,
                        "maxItems": 3,
                        "items": {
                            "type": "object",
                            "additionalProperties": False,
                            "properties": {
                                "common_name": {"type": "string", "minLength": 1, "maxLength": 120},
                                "scientific_name": {"type": "string", "minLength": 1, "maxLength": 160},
                            },
                            "required": ["common_name", "scientific_name"],
                        },
                    },
                },
                "required": [
                    "common_name",
                    "scientific_name",
                    "confidence_label",
                    "discovery_level",
                    "fun_type_label",
                    "habitat_short",
                    "diet_short",
                    "professor_commentary_text",
                    "alternatives",
                ],
            },
            "issue": {
                "type": "object",
                "additionalProperties": False,
                "properties": {
                    "code": {
                        "type": "string",
                        "enum": [
                            "no_bird_visible",
                            "bird_too_small",
                            "image_too_blurry",
                            "image_too_dark",
                            "multiple_birds_ambiguous",
                            "bird_partially_out_of_frame",
                            "fictional_bird_object",
                            "unsupported_image",
                        ],
                    },
                    "user_reason": {"type": "string", "minLength": 1, "maxLength": 200},
                    "professor_commentary_text": {"type": "string", "minLength": 1, "maxLength": 300},
                },
                "required": ["code", "user_reason", "professor_commentary_text"],
            },
        },
        "required": ["success", "result_type"],
        "oneOf": [
            {
                "properties": {"result_type": {"const": "bird_identified"}},
                "required": ["bird"],
            },
            {
                "properties": {"result_type": {"const": "image_unusable"}},
                "required": ["issue"],
            },
        ],
    }
