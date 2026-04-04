import base64
import json

from openai import OpenAI

from app.config import settings
from app.services.prompt_builder import read_prompt


class UpstreamInvalidJsonError(Exception):
    pass


def _build_schema() -> dict:
    return {
        "type": "object",
        "anyOf": [
            {
                "type": "object",
                "additionalProperties": False,
                "required": ["success", "result_type", "bird"],
                "properties": {
                    "success": {"const": True},
                    "result_type": {"const": "bird_identified"},
                    "bird": {"type": "object"},
                },
            },
            {
                "type": "object",
                "additionalProperties": False,
                "required": ["success", "result_type", "issue"],
                "properties": {
                    "success": {"const": True},
                    "result_type": {"const": "image_unusable"},
                    "issue": {"type": "object"},
                },
            },
        ],
    }


def analyze_bird_image(image_bytes: bytes, mime_type: str) -> dict:
    client = OpenAI(api_key=settings.openai_api_key, timeout=settings.request_timeout_seconds)
    base64_image = base64.b64encode(image_bytes).decode("utf-8")

    system_prompt = read_prompt("bird_identification_system.txt")
    format_prompt = read_prompt("bird_identification_format.txt")
    style_prompt = read_prompt("professor_croute_style.txt")

    def run_once(extra_instruction: str = "") -> dict:
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
                    "schema": _build_schema(),
                    "strict": True,
                }
            },
        )
        text = response.output_text
        return json.loads(text)

    try:
        return run_once()
    except Exception:
        try:
            return run_once("Corrige ton JSON immédiatement et respecte strictement le format demandé.")
        except Exception as exc:
            raise UpstreamInvalidJsonError from exc
