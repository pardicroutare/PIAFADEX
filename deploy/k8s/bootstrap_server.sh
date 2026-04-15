#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SECRET_EXAMPLE="${ROOT_DIR}/deploy/k8s/secret.example.env"
SECRET_FILE="${ROOT_DIR}/deploy/k8s/secret.env"

if [[ ! -f "${SECRET_EXAMPLE}" ]]; then
  echo "Fichier manquant: ${SECRET_EXAMPLE}" >&2
  exit 1
fi

if [[ ! -f "${SECRET_FILE}" ]]; then
  cp "${SECRET_EXAMPLE}" "${SECRET_FILE}"
  echo "Fichier créé: ${SECRET_FILE}"
  echo "➡️ Édite ce fichier et remplace OPENAI_API_KEY avant de continuer."
  exit 0
fi

echo "Le fichier ${SECRET_FILE} existe déjà."
echo "Lancement du déploiement K3s..."
"${ROOT_DIR}/deploy/k8s/deploy.sh"
