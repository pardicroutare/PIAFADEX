#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-piafadex}"
DEPLOYMENT="${DEPLOYMENT:-piafadex-backend}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "OFF (kubectl absent)"
  exit 1
fi

if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  echo "OFF (namespace ${NAMESPACE} absent)"
  exit 0
fi

ready_replicas="$(kubectl -n "${NAMESPACE}" get deployment "${DEPLOYMENT}" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
available_replicas="$(kubectl -n "${NAMESPACE}" get deployment "${DEPLOYMENT}" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"

if [[ "${ready_replicas:-0}" =~ ^[0-9]+$ ]] && [[ "${available_replicas:-0}" =~ ^[0-9]+$ ]] && \
   [[ "${ready_replicas:-0}" -ge 1 ]] && [[ "${available_replicas:-0}" -ge 1 ]]; then
  echo "ON"
else
  echo "OFF"
fi
