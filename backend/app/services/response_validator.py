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
    return analyze_adapter.json_schema()
