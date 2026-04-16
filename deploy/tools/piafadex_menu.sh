#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATUS_SCRIPT="${ROOT_DIR}/deploy/tools/status_app.sh"
NAMESPACE="${NAMESPACE:-piafadex}"
DEPLOYMENT="${DEPLOYMENT:-piafadex-backend}"

pause() {
  read -r -p "Appuie sur Entrée pour continuer..." _
}

app_status_menu() {
  clear
  echo "=== État application PIAFADEX ==="
  echo
  if [[ -x "${STATUS_SCRIPT}" ]]; then
    state="$(${STATUS_SCRIPT} || true)"
    echo "Statut global: ${state}"
  else
    echo "Statut global: script status_app.sh introuvable"
  fi
  echo
  if command -v kubectl >/dev/null 2>&1; then
    kubectl -n "${NAMESPACE}" get deploy,po,svc,ingress 2>/dev/null || echo "Aucune ressource trouvée dans ${NAMESPACE}."
  else
    echo "kubectl non installé."
  fi
  echo
  pause
}

server_status_menu() {
  clear
  echo "=== État serveur ==="
  echo
  echo "-- Uptime --"
  uptime || true
  echo
  echo "-- CPU / RAM (top 5) --"
  ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 || true
  echo
  echo "-- Mémoire --"
  free -h || true
  echo
  echo "-- Disque --"
  df -h / || true
  echo
  echo "-- Service k3s --"
  systemctl is-active k3s 2>/dev/null || echo "k3s: statut indisponible"
  echo
  pause
}

k8s_actions_menu() {
  while true; do
    clear
    echo "=== Actions Kubernetes ==="
    echo "1) Logs backend (tail 100)"
    echo "2) Rollout status backend"
    echo "3) Retour"
    echo
    read -r -p "> " choice
    case "${choice}" in
      1)
        kubectl -n "${NAMESPACE}" logs deployment/"${DEPLOYMENT}" --tail=100 || true
        pause
        ;;
      2)
        kubectl -n "${NAMESPACE}" rollout status deployment/"${DEPLOYMENT}" || true
        pause
        ;;
      3) return ;;
      *) echo "Choix invalide"; sleep 1 ;;
    esac
  done
}

main_menu() {
  while true; do
    clear
    echo "=== Menu PIAFADEX serveur ==="
    echo "1) État appli"
    echo "2) État serveur"
    echo "3) Actions Kubernetes"
    echo "4) Quitter"
    echo
    read -r -p "> " choice
    case "${choice}" in
      1) app_status_menu ;;
      2) server_status_menu ;;
      3) k8s_actions_menu ;;
      4) exit 0 ;;
      *) echo "Choix invalide"; sleep 1 ;;
    esac
  done
}

main_menu
