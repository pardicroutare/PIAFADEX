import logging

from fastapi import APIRouter
from fastapi.responses import Response

from app.schemas import GenerateAudioRequest
from app.services.openai_audio import AudioTimeoutError, AudioUnavailableError, generate_professor_audio
from app.utils.errors import error_response

router = APIRouter()
logger = logging.getLogger(__name__)
from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from app.schemas import ApiErrorResponse, GenerateAudioRequest
from app.services.openai_audio import generate_professor_audio

router = APIRouter()


@router.post("/generate-audio")
def generate_audio(payload: GenerateAudioRequest):
    text = (
        f"{payload.common_name}. Oiseau de type {payload.fun_type_label}. "
        f"{payload.habitat_short} {payload.diet_short} {payload.professor_commentary_text}"
    )
    try:
        audio = generate_professor_audio(text)
        return Response(content=audio, media_type="audio/mpeg", headers={"Cache-Control": "no-store"})
    except AudioTimeoutError:
        return error_response(504, "upstream_timeout", "Le fournisseur a dépassé le délai.")
    except AudioUnavailableError:
        return error_response(500, "internal_error", "Service OpenAI indisponible.")
    except Exception:
        logger.exception("Erreur inattendue dans /generate-audio")
        return error_response(500, "internal_error", "Erreur interne.")
        f"{payload.diet_short} {payload.professor_commentary_text}"
    )
    try:
        audio = generate_professor_audio(text)
        return Response(content=audio, media_type="audio/mpeg")
    except TimeoutError:
        raise HTTPException(status_code=504, detail=ApiErrorResponse(success=False, error={"code": "upstream_timeout", "message": "Le fournisseur a dépassé le délai."}).model_dump())
    except Exception:
        raise HTTPException(status_code=500, detail=ApiErrorResponse(success=False, error={"code": "internal_error", "message": "Erreur interne."}).model_dump())
