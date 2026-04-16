#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-piafadex}"
SERVICE="${SERVICE:-piafadex-backend}"
LOCAL_PORT="${LOCAL_PORT:-8000}"
TARGET_PORT="${TARGET_PORT:-80}"

PF_LOG="${PF_LOG:-/tmp/piafadex-port-forward-health.log}"

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

echo "[INFO] GET /health"
RESPONSE="$(curl -fsS "http://127.0.0.1:${LOCAL_PORT}/health")"
echo "$RESPONSE"

echo "[OK] Health check réussi."
