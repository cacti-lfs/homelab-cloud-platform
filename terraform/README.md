# Terraform

**Etat actuel :** Actuellement, le terraform est écrit de sorte à créer une VM "Hello World" de Test

**A Savoir:** Il sera nécessaire de créer un `terraform.tfvars` qui contiendra vos variables. De plus certaines variables du `main.tf` peuvent changer en fonction de votre version de `bpg` (Provider Proxmox) et/ou du matériel utilisé.

### 1. LES TEMPLATES (Les "Golden Images")

Pour les templates, l'objectif est de savoir instantanément quel est l'OS et le dimensionnement matériel (Sizing) pour cloner rapidement.

**La Syntaxe :** `tpl-[OS][VER]-[CPU]c-[RAM]g`

* **tpl** : Préfixe pour les identifier (et les filtrer).
* **[OS]** : Trigramme de l'OS.
* **[VER]** : Version courte ou Codename.
* **[CPU]c** : Nombre de vCores.
* **[RAM]g** : Quantité de RAM en Go.

**Le Dictionnaire des Codes :**

| OS | Code | Version | Code Version |
| --- | --- | --- | --- |
| **Ubuntu** | `ubu` | 22.04 (Jammy) | `jam` |
|  |  | 24.04 (Noble) | `nob` |
| **Debian** | `deb` | 11 (Bullseye) | `11` |
|  |  | 12 (Bookworm) | `12` |
| **Alpine** | `alp` | 3.19 | `319` |
| **Rocky** | `rck` | 9.3 | `9` |

**Exemples concrets pour ton Proxmox :**

* `tpl-ubu-jam-2c-4g` (Ubuntu 22.04, 2 vCPU, 4 Go RAM) -> *Ton standard pour K3s Master ?*
* `tpl-deb-12-1c-512m` (Debian 12, 1 vCPU, 512 Mo RAM) -> *Pour des petits services.*
* `tpl-alp-319-1c-256m` (Alpine, très léger) -> *Pour des conteneurs LXC.*

---

### 2. LES VIRTUAL MACHINES (L'Infrastructure Active)


**Mon conseil d'Architecte :**
Le nom du serveur (Hostname) doit refléter sa **FONCTION** et sa **LOCALISATION**.
L'OS et la version sont gérés par les **TAGS** Proxmox.

**La Syntaxe :** `[ENV]-[LOC]-[ROLE]-[ID]`

* **[ENV]** : Environnement (prd = Prod, lab = Labo/Test).
* **[LOC]** : Localisation (pve = Cluster Proxmox, rpi = Raspberry Pi).
* **[ROLE]** : La fonction du serveur (k3s-m, k3s-w, db, mon).
* **[ID]** : Numéro unique (01, 02...).

**Exemples pour ton Infra :**

| Machine | Nom Proposé (Hostname) | Tags Proxmox (Visuels) |
| --- | --- | --- |
| K3s Master | `prd-pve-k3s-m01` | `ubuntu`, `24.04`, `master` |
| K3s Worker 1 | `prd-pve-k3s-w01` | `ubuntu`, `24.04`, `worker` |
| K3s Worker 2 | `prd-pve-k3s-w02` | `ubuntu`, `24.04`, `worker` |
| Monitoring | `prd-pve-mon-01` | `debian`, `12`, `grafana` |
| Test Rapide | `lab-pve-test-01` | `alpine`, `temp` |

---

### 3. LA STRATÉGIE DES IDs (Le Rangement)

* **100 - 199 : Infrastructure Core** (Routeurs virtuels, DNS, VPN si virtualisé).
* **200 - 299 : Cluster Kubernetes** (Tes nœuds K3s).
* *200 = Master*
* *210+ = Workers*


* **300 - 399 : Services de Données** (Bases de données, NAS, Stockage).
* **400 - 499 : Monitoring & Management** (Grafana, Gitlab, Jenkins).
* **9000+ : Templates** (Comme dit plus haut).
