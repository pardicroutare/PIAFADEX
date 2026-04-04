from openai import OpenAI

from app.config import settings
from app.services.prompt_builder import read_prompt


def generate_professor_audio(text: str) -> bytes:
    client = OpenAI(api_key=settings.openai_api_key, timeout=settings.request_timeout_seconds)
    style_prompt = read_prompt("audio_style_prompt.txt")
    response = client.audio.speech.create(
        model=settings.openai_model_audio,
        voice="alloy",
        format="mp3",
        input=f"{style_prompt}\n\nTexte à lire:\n{text}",
    )
    return response.read()
