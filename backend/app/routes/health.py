from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
def health() -> dict:
    return {"ok": True, "service": "piafadex-backend", "version": "1.0.0"}
