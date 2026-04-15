#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-piafadex}"
IMAGE_NAME="${IMAGE_NAME:-piafadex-backend:local}"
SECRET_FILE="${SECRET_FILE:-${ROOT_DIR}/deploy/k8s/secret.env}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Commande manquante: $1" >&2
    exit 1
  fi
}

require_cmd kubectl
require_cmd sudo

if ! command -v docker >/dev/null 2>&1 && ! command -v nerdctl >/dev/null 2>&1; then
  echo "Installe Docker ou nerdctl pour builder l'image locale." >&2
  exit 1
fi

if [[ ! -f "${SECRET_FILE}" ]]; then
  echo "Fichier secret introuvable: ${SECRET_FILE}" >&2
  echo "Copie deploy/k8s/secret.example.env vers deploy/k8s/secret.env et renseigne OPENAI_API_KEY." >&2
  exit 1
fi

echo "[1/5] Build image ${IMAGE_NAME}"
if command -v docker >/dev/null 2>&1; then
  docker build -t "${IMAGE_NAME}" "${ROOT_DIR}/backend"

  echo "[2/5] Import image dans containerd k3s"
  TMP_TAR="$(mktemp /tmp/piafadex-image-XXXXXX.tar)"
  docker save "${IMAGE_NAME}" -o "${TMP_TAR}"
  sudo k3s ctr images import "${TMP_TAR}"
  rm -f "${TMP_TAR}"
else
  nerdctl --namespace k8s.io build -t "${IMAGE_NAME}" "${ROOT_DIR}/backend"
fi

echo "[3/5] Namespace et secret"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/namespace.yaml"
kubectl -n "${NAMESPACE}" create secret generic piafadex-secrets \
  --from-env-file="${SECRET_FILE}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "[4/5] Déploiement Kubernetes"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/configmap.yaml"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/deployment.yaml"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/service.yaml"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/ingress.yaml"

echo "[5/5] Vérification"
kubectl -n "${NAMESPACE}" rollout status deployment/piafadex-backend
kubectl -n "${NAMESPACE}" get pods,svc,ingress

echo "Déploiement terminé."
