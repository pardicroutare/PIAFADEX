from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from app.schemas import ApiErrorResponse
from app.services.image_utils import ALLOWED_CONTENT_TYPES, MAX_FILE_SIZE_BYTES
from app.services.openai_vision import UpstreamInvalidJsonError, analyze_bird_image

router = APIRouter()


@router.post("/analyze-bird")
async def analyze_bird(file: UploadFile = File(...), client_context: str | None = Form(default=None)):
    _ = client_context
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(status_code=400, detail=ApiErrorResponse(success=False, error={"code": "unsupported_image", "message": "Type de fichier non supporté."}).model_dump())

    image_bytes = await file.read()
    if len(image_bytes) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(status_code=413, detail=ApiErrorResponse(success=False, error={"code": "file_too_large", "message": "Image trop lourde (max 10MB)."}).model_dump())

    try:
        payload = analyze_bird_image(image_bytes=image_bytes, mime_type=file.content_type or "image/jpeg")
        return payload
    except UpstreamInvalidJsonError:
        raise HTTPException(status_code=504, detail=ApiErrorResponse(success=False, error={"code": "upstream_invalid_json", "message": "Réponse upstream invalide."}).model_dump())
    except TimeoutError:
        raise HTTPException(status_code=504, detail=ApiErrorResponse(success=False, error={"code": "upstream_timeout", "message": "Le fournisseur a dépassé le délai."}).model_dump())
    except Exception:
        raise HTTPException(status_code=500, detail=ApiErrorResponse(success=False, error={"code": "internal_error", "message": "Erreur interne."}).model_dump())
