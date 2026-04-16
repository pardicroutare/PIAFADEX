#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --image /chemin/vers/image.jpg [--locale fr-FR] [--app-version 1.0.0]

Variables d'environnement optionnelles:
  NAMESPACE   (défaut: piafadex)
  SERVICE     (défaut: piafadex-backend)
  LOCAL_PORT  (défaut: 8000)
  TARGET_PORT (défaut: 80)
USAGE
}

IMAGE_PATH=""
LOCALE="fr-FR"
APP_VERSION="1.0.0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      IMAGE_PATH="$2"
      shift 2
      ;;
    --locale)
      LOCALE="$2"
      shift 2
      ;;
    --app-version)
      APP_VERSION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Option inconnue: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$IMAGE_PATH" ]]; then
  echo "[ERREUR] --image est obligatoire." >&2
  usage
  exit 1
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
  echo "[ERREUR] Fichier introuvable: $IMAGE_PATH" >&2
  exit 1
fi

ext="${IMAGE_PATH##*.}"
ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
case "$ext" in
  jpg|jpeg)
    MIME_TYPE="image/jpeg"
    ;;
  png)
    MIME_TYPE="image/png"
    ;;
  webp)
    MIME_TYPE="image/webp"
    ;;
  *)
    echo "[ERREUR] Extension non supportée: .$ext (utilise jpg/jpeg/png/webp)" >&2
    exit 1
    ;;
esac

NAMESPACE="${NAMESPACE:-piafadex}"
SERVICE="${SERVICE:-piafadex-backend}"
LOCAL_PORT="${LOCAL_PORT:-8000}"
TARGET_PORT="${TARGET_PORT:-80}"
PF_LOG="${PF_LOG:-/tmp/piafadex-port-forward-analyze.log}"

cleanup() {
  if [[ -n "${PF_PID:-}" ]] && kill -0 "$PF_PID" >/dev/null 2>&1; then
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "[INFO] Port-forward ${SERVICE}:${TARGET_PORT} -> 127.0.0.1:${LOCAL_PORT}"
kubectl -n "$NAMESPACE" port-forward "svc/${SERVICE}" "${LOCAL_PORT}:${TARGET_PORT}" >"$PF_LOG" 2>&1 &
PF_PID=$!
sleep 2

echo "[INFO] POST /analyze-bird avec image: $IMAGE_PATH"
curl -i -sS -X POST "http://127.0.0.1:${LOCAL_PORT}/analyze-bird" \
  -F "file=@${IMAGE_PATH};type=${MIME_TYPE}" \
  -F "client_context={\"app_version\":\"${APP_VERSION}\",\"locale\":\"${LOCALE}\"}"

echo

echo "[OK] Requête envoyée. Vérifie status HTTP + JSON de réponse ci-dessus."
