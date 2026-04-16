from pathlib import Path

from app.config import settings


def ensure_temp_dir() -> Path:
    path = Path(settings.temp_dir)
    path.mkdir(parents=True, exist_ok=True)
    return path
