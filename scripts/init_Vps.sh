#!/bin/bash

set -euo pipefail

log() {
	echo "[INFO] $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Ce script doit être lancé en root ou avec sudo."
        exit 1
    fi
}

update_system() {
    log "Mise à jour du système"
    apt update
    apt upgrade -y
}

install_base_packages() {
    log "Installation des paquets de base"
    apt install -y \
        curl \
        vim \
        ufw \
        fail2ban \
        zsh
}


configure_ufw() {
    log "Configuration UFW"
    ufw allow OpenSSH
    ufw --force enable
}

configure_fail2ban() {
    log "Activation de Fail2Ban"
    systemctl enable fail2ban
    systemctl restart fail2ban
}

main() {
    check_root
    update_system
    install_base_packages
    configure_ufw
    configure_fail2ban
    log "Initialisation terminée"
}

main
