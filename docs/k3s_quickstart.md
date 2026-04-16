# PIAFADEX backend sur K3s (quickstart)

## Prérequis
- K3s installé sur le serveur.
- `kubectl` opérationnel.
- Docker (ou nerdctl) installé pour builder l'image locale.

## Déploiement en 5 minutes
1. Cloner le repo.
2. Lancer le bootstrap:
   ```bash
   ./deploy/k8s/bootstrap_server.sh
   ```
   > Si `secret.env` est absent, le script le crée puis s'arrête.
3. Éditer `deploy/k8s/secret.env` avec ta vraie clé OpenAI.
4. Relancer le bootstrap:
   ```bash
   ./deploy/k8s/bootstrap_server.sh
   ```

Le script:
- build l'image Docker `piafadex-backend:local`,
- l'importe dans K3s,
- crée namespace/config/secret,
- déploie Deployment + Service + Ingress,
- attend le rollout.

## Vérifications
```bash
kubectl -n piafadex get pods,svc,ingress
kubectl -n piafadex logs deploy/piafadex-backend -f
kubectl -n piafadex port-forward svc/piafadex-backend 8000:80
curl http://127.0.0.1:8000/health
```

## Notes
- L'Ingress utilise `piafadex.local` et `traefik` (par défaut sur K3s). Adapte l'hôte si besoin.
- Les fichiers temporaires backend sont stockés dans un volume `emptyDir` (`/tmp/piafadex`) non persistant.
- Pour mettre à jour le backend, relance simplement `./deploy/k8s/deploy.sh` (le script force un `rollout restart` pour appliquer la nouvelle image locale).

## Dépannage rapide
- **`permission denied` sur Docker (`/var/run/docker.sock`)**
  ```bash
  sudo usermod -aG docker "$USER"
  newgrp docker
  docker info
  ```
  Puis relancer:
  ```bash
  ./deploy/k8s/deploy.sh
  ```
  > Alternative immédiate: `sudo ./deploy/k8s/deploy.sh`
- **Deployment bloqué**
  ```bash
  kubectl -n piafadex get pods -l app=piafadex-backend -o wide
  kubectl -n piafadex logs deploy/piafadex-backend --tail=200
  kubectl -n piafadex logs deploy/piafadex-backend --previous --tail=200
  ```


## Commande ON/OFF
```bash
./deploy/tools/status_app.sh
```

## Menu serveur interactif
```bash
# lancer à la demande
./deploy/tools/piafadex_menu.sh

# ou l'installer au login bash
./deploy/tools/install_menu.sh
```
