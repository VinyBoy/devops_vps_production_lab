### Objectif principal :

Construire un socle DevOps solide en administrant un VPS Linux sécurisé, conteneurisé, observable et documenté.

### Nom du projet 

Devops VPS Production Lab

### Objectif du repo

Documenter la mise en place d’un VPS Linux sécurisé et exploitable, capable d’héberger plusieurs services conteneurisés derrière un reverse proxy HTTPS, avec monitoring, backups et documentation d’exploitation.

### Stack Cible

- Linux Debian 12 ou Ubuntu Server
- SSH
- UFW
- Fail2ban ou CrowdSec
- Docker
- Docker Compose
- Traefik ou Nginx reverse proxy
- Let’s Encrypt
- Prometheus
- Grafana
- Node Exporter
- Bash
- Makefile
- GitHub
- Markdown
- Mermaid ou Excalidraw pour les schémas

## VPS environment

- Provider: VPS cloud provider
- OS: Debian GNU/Linux 13
- Virtualization: KVM
- Architecture: x86_64
- Admin panel: Plesk
- Access method: SSH with key authentication
- Public IP: redacted
- Hostname: redacted

### J1 - 20 juin 2026

- Creation d'un projet Github
- Creation :
	- Fichier 
		- README.md
		- .gitignore
		- .env.exemple
	- Dossier :
		- diagrams
		- docs
		- screenshot
		- scripts

- Achat d'un VPS Linux S sous Debian
- Premiere connexion en SSH sur l'ip du serveur en root
- Mise a jour du systeme avec
	- sudo apt update && sudo apt upgrade
	- hostnamectl

### Configuration du VPS

- Installation de git sur le serveur
- git clone de ce repo

**Commandes utiles**

```
	- sudo apt update && sudo apt upgrade
	- hostnamectl
	- uname -a
	- id
	- ssh

```
