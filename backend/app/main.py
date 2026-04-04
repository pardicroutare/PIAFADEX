from fastapi import FastAPI
from fastapi.responses import JSONResponse

from app.config import settings
from app.routes.analyze import router as analyze_router
from app.routes.audio import router as audio_router
from app.routes.health import router as health_router
from app.utils.logging_config import configure_logging

configure_logging(settings.log_level)

app = FastAPI(title="PIAFADEX Backend", version="1.0.0")
app.include_router(health_router)
app.include_router(analyze_router)
app.include_router(audio_router)


@app.exception_handler(Exception)
async def unhandled_exception_handler(_, exc: Exception):
    return JSONResponse(status_code=500, content={"success": False, "error": {"code": "internal_error", "message": str(exc)}})
