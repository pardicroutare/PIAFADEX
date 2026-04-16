from openai import APIConnectionError, APITimeoutError, OpenAI

from app.config import settings
from app.services.prompt_builder import read_prompt


class AudioTimeoutError(Exception):
    pass


class AudioUnavailableError(Exception):
    pass


def generate_professor_audio(text: str) -> bytes:
    if not settings.openai_api_key:
        raise AudioUnavailableError("OPENAI_API_KEY manquante")

    client = OpenAI(api_key=settings.openai_api_key, timeout=settings.request_timeout_seconds)
    style_prompt = read_prompt("audio_style_prompt.txt")

    try:
        response = client.audio.speech.create(
            model=settings.openai_model_audio,
            voice="alloy",
            format="mp3",
            input=f"{style_prompt}\n\nTexte à lire:\n{text}",
        )
    except APITimeoutError as exc:
        raise AudioTimeoutError from exc
    except APIConnectionError as exc:
        raise AudioUnavailableError from exc

    return response.read()
