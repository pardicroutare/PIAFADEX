# Checklist Debian backend

1. Installer Python, venv, pip, git, curl, ffmpeg.
2. Créer `/opt/piafadex/backend`, `/var/log/piafadex`, `/tmp/piafadex`.
3. Déployer le projet et installer les dépendances.
4. Configurer `.env`.
5. Installer et démarrer `piafadex.service`.
6. Tester `/health`, `/analyze-bird`, `/generate-audio`.
