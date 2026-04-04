from app.schemas import AnalyzeBirdResponse


def validate_analyze_payload(payload: dict) -> AnalyzeBirdResponse:
    return AnalyzeBirdResponse.model_validate(payload)  # type: ignore[attr-defined]
