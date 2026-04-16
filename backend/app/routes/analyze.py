import json
import logging

from fastapi import APIRouter, File, Form, UploadFile

from app.services.image_utils import ALLOWED_CONTENT_TYPES, MAX_FILE_SIZE_BYTES
from app.services.openai_vision import (
    UpstreamInvalidJsonError,
    UpstreamRequestError,
    UpstreamTimeoutError,
    UpstreamUnavailableError,
    analyze_bird_image,
)
from app.utils.errors import error_response

router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/analyze-bird")
async def analyze_bird(file: UploadFile = File(...), client_context: str | None = Form(default=None)):
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        return error_response(400, "unsupported_image", "Type de fichier non supporté.")

    if client_context:
        try:
            json.loads(client_context)
        except json.JSONDecodeError:
            return error_response(400, "bad_request", "client_context doit être un JSON valide.")

    image_bytes = await file.read()
    if not image_bytes:
        return error_response(400, "bad_request", "Fichier image vide.")

    if len(image_bytes) > MAX_FILE_SIZE_BYTES:
        return error_response(413, "file_too_large", "Image trop lourde (max 10MB).")

    try:
        return analyze_bird_image(image_bytes=image_bytes, mime_type=file.content_type or "image/jpeg")
    except UpstreamInvalidJsonError:
        logger.warning("Réponse upstream JSON invalide")
        return error_response(504, "upstream_invalid_json", "Réponse upstream invalide.")
    except UpstreamTimeoutError:
        return error_response(504, "upstream_timeout", "Le fournisseur a dépassé le délai.")
    except UpstreamRequestError:
        logger.exception("Requête upstream invalide dans /analyze-bird")
        return error_response(500, "internal_error", "Requête upstream invalide.")
    except UpstreamUnavailableError:
        return error_response(500, "internal_error", "Service OpenAI indisponible.")
    except Exception:
        logger.exception("Erreur inattendue dans /analyze-bird")
        return error_response(500, "internal_error", "Erreur interne.")
