# Contrats API

## GET /health
Réponse :
```json
{"ok": true, "service": "piafadex-backend", "version": "1.0.0"}
```

## POST /analyze-bird
- Content-Type: `multipart/form-data`
- Champs: `file` (obligatoire), `client_context` (facultatif)
- Réponses: `200`, `400`, `413`, `504`, `500`

## POST /generate-audio
- Content-Type: `application/json`
- Réponse: `audio/mpeg`
- Réponses d’erreur: `400`, `500`, `504`
