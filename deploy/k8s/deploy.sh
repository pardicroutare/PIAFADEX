#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NAMESPACE="${NAMESPACE:-piafadex}"
IMAGE_NAME="${IMAGE_NAME:-piafadex-backend:local}"
SECRET_FILE="${SECRET_FILE:-${ROOT_DIR}/deploy/k8s/secret.env}"
DOCKER_RUNNER=""
K3S_CTR_RUNNER=""

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Commande manquante: $1" >&2
    exit 1
  fi
}

require_cmd kubectl
require_cmd python3

if ! command -v docker >/dev/null 2>&1 && ! command -v nerdctl >/dev/null 2>&1; then
  echo "Installe Docker ou nerdctl pour builder l'image locale." >&2
  exit 1
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    DOCKER_RUNNER="docker"
  elif command -v sudo >/dev/null 2>&1 && sudo -n docker info >/dev/null 2>&1; then
    DOCKER_RUNNER="sudo docker"
  else
    echo "Impossible d'accéder à Docker (permission denied)." >&2
    echo "➡️ Solutions:" >&2
    echo "   - relancer avec sudo: sudo ./deploy/k8s/deploy.sh" >&2
    echo "   - ou ajouter l'utilisateur au groupe docker puis reconnecter:" >&2
    echo "     sudo usermod -aG docker \"$USER\"" >&2
    exit 1
  fi
fi

if [[ ! -f "${SECRET_FILE}" ]]; then
  echo "Fichier secret introuvable: ${SECRET_FILE}" >&2
  echo "Copie deploy/k8s/secret.example.env vers deploy/k8s/secret.env et renseigne OPENAI_API_KEY." >&2
  exit 1
fi

echo "[1/6] Validation syntaxe backend"
python3 -m compileall "${ROOT_DIR}/backend/app" >/dev/null

if command -v k3s >/dev/null 2>&1; then
  if k3s ctr images ls >/dev/null 2>&1; then
    K3S_CTR_RUNNER="k3s ctr"
  elif command -v sudo >/dev/null 2>&1 && sudo -n k3s ctr images ls >/dev/null 2>&1; then
    K3S_CTR_RUNNER="sudo k3s ctr"
  elif command -v sudo >/dev/null 2>&1; then
    K3S_CTR_RUNNER="sudo k3s ctr"
  else
    echo "Impossible d'accéder à 'k3s ctr'. Installe sudo ou exécute ce script avec les droits nécessaires." >&2
    exit 1
  fi
fi

echo "[2/6] Build image ${IMAGE_NAME}"
if command -v docker >/dev/null 2>&1; then
  ${DOCKER_RUNNER} build -t "${IMAGE_NAME}" "${ROOT_DIR}/backend"

  echo "[3/6] Import image dans containerd k3s"
  TMP_TAR="$(mktemp /tmp/piafadex-image-XXXXXX.tar)"
  ${DOCKER_RUNNER} save "${IMAGE_NAME}" -o "${TMP_TAR}"
  ${K3S_CTR_RUNNER} images import "${TMP_TAR}"
  rm -f "${TMP_TAR}"
else
  nerdctl --namespace k8s.io build -t "${IMAGE_NAME}" "${ROOT_DIR}/backend"
fi

echo "[4/6] Namespace et secret"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/namespace.yaml"
kubectl -n "${NAMESPACE}" create secret generic piafadex-secrets \
  --from-env-file="${SECRET_FILE}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "[5/6] Déploiement Kubernetes"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/configmap.yaml"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/deployment.yaml"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/service.yaml"
kubectl apply -f "${ROOT_DIR}/deploy/k8s/ingress.yaml"
# Le tag d'image est constant (local) : on force un restart pour prendre la nouvelle image importée.
kubectl -n "${NAMESPACE}" rollout restart deployment/piafadex-backend >/dev/null

echo "[6/6] Vérification"
kubectl -n "${NAMESPACE}" rollout status deployment/piafadex-backend
kubectl -n "${NAMESPACE}" get pods,svc,ingress

echo "Déploiement terminé."
