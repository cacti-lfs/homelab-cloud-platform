# Dossier de Conception : HomeLab

**Cible :** Cluster Proxmox VE & kubernetes (K3s)

**Date :** Janvier 2026

---

## 1. Vision du Projet	

L'objectif est de mettre en place une infrastructure de type "Cloud Privé" hautement disponible (HA) utilisant du matériel de récupération (Mini-PC) pour simuler un environnement de production DevOps moderne. Ce lab met l'accent sur l'**Infrastructure as Code (IaC)**, le **versionning** et l'**observabilité**. 

---

## 2. Inventaire Matériel (Hardware) 

| Noeud      | Modèle         | Processeur    | RAM   | Rôle Proxmox             |
| ---------- | -------------- | ------------- | ----- | ------------------------ |
| **PVE-01** | Tiny 715q      | AMD Ryzen Pro | 16 Go | Quorum + VM K3s Master 1 |
| **PVE-02** | Tiny 715q      | AMD Ryzen Pro | 16 Go | Quorum + VM K3s Master 2 |
| **PVE-03** | Tiny 710q      | Intel Core i5 | 12 Go | Quorum + VM K3s Master 3 |
| **Extra**  | Raspberry Pi 4 | ARM v8        | -     | Services annexes         |

- **Réseau :** Box Internet standard (DHCP), câblage Ethernet RJ45
- **Stockage :** SSD et HDD locaux sur chaque noeud (Possible Cluster storage via Longhorn)



## 3. Architecture Physique (Hardware & Connectivité)

Le cluster est organisé en "maillage" via le switch de la box internet.

```markdown
       [ BOX INTERNET / ROUTER ]
       (Passerelle: 192.168.1.1)
                  │
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
[ HP 715q ]   [ HP 715q ]   [ HP 710q ]
(PVE-01)      (PVE-02)      (PVE-03)
 16 Go RAM     16 Go RAM     12 Go RAM
```

## 4. Architecture Logique (Software Stack)

L'infrastructure est découpée en couches logiques pour assurer la séparation des responsabilités.

### A. Couche de Virtualisation (Proxmox)

- **Cluster Corosync :** Les 3 nœuds sont liés. Si un nœud tombe, les VM peuvent être redémarrées automatiquement sur les autres (High Availability).
- **Réseau Virtuel :** Utilisation d'un pont Linux (`vmbr0`) sur chaque nœud.

### B. Couche d'orchestration (K3s)

- **Topologie :** 3 VM (1 par nœud physique) formant un plan de contrôle HA avec `etcd` embarqué.
- **Networking :** **Kube-vip :** Fournit une IP virtuelle (ex: `192.168.1.50`) pour l'accès au cluster.
  - **MetalLB 	:** Gère un pool d'IPs locales pour exposer les services 	(LoadBalancer).
- **Stockage :** * **Longhorn :** Système de stockage distribué qui réplique les données des volumes sur les 3 VM.

## 5. La Stack Logicielle devOps (Services Cibles)

| **Catégorie**      | Outil recommandé | Rôle                                            |
| ------------------ | ---------------- | ----------------------------------------------- |
| **CI&CD & GitOps** | **ArgoCD**       | Synchronise l'état du cluster avec un dépôt Git |
| **Source de code** | **Gitea**        | Serveur Git léger auto-hebergé                  |
| **Observabilité**  | **Grafana/Loki** | tableaux de bord et centralisation des logs     |
| **Sécurité**       | **Vaultwarden**  | Gestionnaire de mots de passe                   |
| **Réseau/DNS**     | **AdGuard Home** | Filtrge DNS et blocage de publicités            |
| **Ingress**        | **Traefik**      | Reverse-proxy natif K3s avec gestion SSL        |

## 6. Schéma de Flux (Logique de Requête)

```markdown
[Utilisateur] --> [IP Virtuelle: 192.168.1.50]
                       │
                       ▼
             [Ingress Controller: Traefik]
                       │
        ┌──────────────┴──────────────┐
        ▼                             ▼
[Service: Gitea]             [Service: Grafana]
        │                             │
 [Volume Longhorn]            [Volume Longhorn]
 (Répliqué sur 3 nœuds)       (Répliqué sur 3 nœuds)
```

## Roadmap d'implémentation

- [ ] Phase 1: Installation de Proxmox sur les 3 noeuds et créations du Cluster PVE
- [ ] Phase 2 : Provisioning de 3 VM Linux via Terraform
- [ ] Phase 3 : Déploiement de K3s en mode HA avec ansible
- [ ] Phase 4 : Installation de Longhorn pour le stockage et MetalLB pour le réseau
- [ ] Phase 5 : Déploiement d'ArgoCD et début de la configuration GitOps