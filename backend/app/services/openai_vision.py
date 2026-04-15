import base64
import json

from openai import APIConnectionError, APITimeoutError, OpenAI
from pydantic import ValidationError

from app.config import settings
from app.services.prompt_builder import read_prompt
from app.services.response_validator import analyze_json_schema, validate_analyze_payload


class UpstreamInvalidJsonError(Exception):
    pass


class UpstreamTimeoutError(Exception):
    pass


class UpstreamUnavailableError(Exception):
    pass


def _client() -> OpenAI:
    if not settings.openai_api_key:
        raise UpstreamUnavailableError("OPENAI_API_KEY manquante")
    return OpenAI(api_key=settings.openai_api_key, timeout=settings.request_timeout_seconds)


def analyze_bird_image(image_bytes: bytes, mime_type: str) -> dict:
    client = _client()
    base64_image = base64.b64encode(image_bytes).decode("utf-8")

    system_prompt = read_prompt("bird_identification_system.txt")
    format_prompt = read_prompt("bird_identification_format.txt")
    style_prompt = read_prompt("professor_croute_style.txt")

    def run_once(extra_instruction: str = "") -> dict:
        try:
            response = client.responses.create(
                model=settings.openai_model_analyze,
                input=[
                    {
                        "role": "system",
                        "content": [{"type": "input_text", "text": system_prompt + "\n\n" + format_prompt + "\n\n" + style_prompt}],
                    },
                    {
                        "role": "user",
                        "content": [
                            {"type": "input_text", "text": f"Analyse cette image. {extra_instruction}".strip()},
                            {"type": "input_image", "image_url": f"data:{mime_type};base64,{base64_image}"},
                        ],
                    },
                ],
                text={
                    "format": {
                        "type": "json_schema",
                        "name": "analyze_bird_response",
                        "schema": analyze_json_schema(),
                        "strict": True,
                    }
                },
            )
        except APITimeoutError as exc:
            raise UpstreamTimeoutError from exc
        except APIConnectionError as exc:
            raise UpstreamUnavailableError from exc

        parsed = json.loads(response.output_text)
        return validate_analyze_payload(parsed)

    try:
        return run_once()
    except (json.JSONDecodeError, ValidationError, ValueError, TypeError):
        try:
            return run_once("Corrige ton JSON immédiatement et respecte strictement le format demandé.")
        except (json.JSONDecodeError, ValidationError, ValueError, TypeError) as exc:
            raise UpstreamInvalidJsonError from exc
