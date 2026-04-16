#!/usr/bin/env bash
set -euo pipefail

MODE="safe"
if [[ "${1:-}" == "--hard" ]]; then
  MODE="hard"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERREUR] Cette commande doit être lancée dans un dépôt git."
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "main" ]]; then
  echo "[INFO] Branche actuelle: $current_branch"
  echo "[INFO] Bascule vers main..."
  git checkout main
fi

echo "[INFO] Récupération des dernières références..."
git fetch origin main

if [[ "$MODE" == "hard" ]]; then
  echo "[ATTENTION] Mode --hard: reset local vers origin/main + nettoyage fichiers non suivis"
  git reset --hard origin/main
  git clean -fd -e deploy/k8s/secret.env
  echo "[OK] Dépôt aligné exactement sur origin/main"
  exit 0
fi

has_changes=0
if [[ -n "$(git status --porcelain)" ]]; then
  has_changes=1
fi

if [[ "$has_changes" -eq 1 ]]; then
  stash_label="auto-sync-$(date -u +%Y%m%d-%H%M%S)"
  echo "[INFO] Changements locaux détectés: création d'un stash ($stash_label)"
  git stash push --include-untracked -m "$stash_label" >/dev/null
fi

echo "[INFO] Mise à jour rapide vers origin/main..."
git pull --ff-only origin main

if [[ "$has_changes" -eq 1 ]]; then
  echo "[INFO] Restauration du stash..."
  if git stash pop; then
    echo "[OK] Mises à jour appliquées + changements locaux restaurés."
  else
    echo "[WARNING] Conflit lors du 'stash pop'. Résous les conflits puis commit."
    exit 1
  fi
else
  echo "[OK] Dépôt à jour, aucun changement local à restaurer."
fi
