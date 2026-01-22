# Ansible

Pour une meilleure isolation des environnements, il est recommandé de créer des environnements virtualisés python et d'utiliser le `requirements.txt` pour que les dépendances soient communes à celles du projet homelab-cloud-platform.

## Création d'un environnement `.venv`
- Installation de python

```bash
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.12 python3.12-venv -y
```

- Création de l'environnement
```bash
/usr/bin/python3.12 -m venv ./.venv
```
- Activation de l'environnement
```bash
source .venv/bin/activate
```

- Mise à jour de pip
```bash
pip install --upgrade pip
```

- Installation des dépendances via le `requirements.txt`
```bash
pip install -r requirements.txt
```