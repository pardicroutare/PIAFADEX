# PIAFADEX

Le Pokédex des oiseaux.

## Structure
- `docs/` : paquet technique V1 et contrats.
- `backend/` : FastAPI (analyse image + audio mp3).
- `frontend/` : squelette Flutter Android.

## Démarrage backend
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
