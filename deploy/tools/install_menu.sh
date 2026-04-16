#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MENU_CMD="${ROOT_DIR}/deploy/tools/piafadex_menu.sh"
BASHRC="${HOME}/.bashrc"
MARK_START="# >>> piafadex-menu >>>"
MARK_END="# <<< piafadex-menu <<<"

if [[ ! -x "${MENU_CMD}" ]]; then
  echo "Script menu introuvable: ${MENU_CMD}" >&2
  exit 1
fi

if grep -q "${MARK_START}" "${BASHRC}" 2>/dev/null; then
  echo "Bloc menu déjà présent dans ${BASHRC}."
  exit 0
fi

cat >> "${BASHRC}" <<EOB

${MARK_START}
# Lance le menu PIAFADEX à la connexion interactive
if [[ -n "\$PS1" ]]; then
  ${MENU_CMD}
fi
${MARK_END}
EOB

echo "Bloc ajouté à ${BASHRC}."
echo "Reconnecte-toi au shell pour voir le menu automatiquement."
