# PIAFADEX

Le Pokédex des oiseaux.

## Structure
- `docs/` : paquet technique V1 et contrats.
- `backend/` : FastAPI (analyse image + audio mp3).
- `frontend/` : squelette Flutter Android.

## Démarrage backend
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```


## Déploiement K3s (backend)
```bash
# 1) clone/pull le repo
# 2) bootstrap (crée secret.env si absent)
./deploy/k8s/bootstrap_server.sh

# 3) édite deploy/k8s/secret.env (OPENAI_API_KEY)
# 4) relance le bootstrap (déploie sur k3s)
./deploy/k8s/bootstrap_server.sh
```

Déploiement direct possible : `./deploy/k8s/deploy.sh`.
Guide détaillé: `docs/k3s_quickstart.md`.

Si Docker renvoie `permission denied` sur `/var/run/docker.sock`:
```bash
sudo usermod -aG docker "$USER"
newgrp docker
docker info
```
Puis relancer `./deploy/k8s/deploy.sh` (ou `sudo ./deploy/k8s/deploy.sh` en dépannage immédiat).


## Outils serveur (ON/OFF + menu)
```bash
# statut simple application
./deploy/tools/status_app.sh

# menu interactif
./deploy/tools/piafadex_menu.sh

# installation auto du menu à la connexion bash
./deploy/tools/install_menu.sh
```
