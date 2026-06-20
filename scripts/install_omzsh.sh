#!/bin/bash

set -euo pipefail

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

check_user() {
    log "Vérification de l'utilisateur"

    if [ -z "${USER:-}" ]; then
        error "La variable USER n'existe pas ou est vide."
    fi

    if [ "$USER" = "root" ]; then
        error "Ce script ne doit pas être lancé avec l'utilisateur root."
    fi

    if ! id "$USER" >/dev/null 2>&1; then
        error "L'utilisateur '$USER' n'existe pas sur le système."
    fi

    log "Utilisateur valide : $USER"
}

check_dependencies() {
    log "Vérification des dépendances"

    if ! command -v curl >/dev/null 2>&1; then
        error "curl n'est pas installé."
    fi

    if ! command -v zsh >/dev/null 2>&1; then
        error "zsh n'est pas installé."
    fi
}

install_omzsh() {
    log "Installation de Oh My Zsh"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Oh My Zsh non trouvé, installation..."

        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        log "Oh My Zsh installé"
    else
        log "Oh My Zsh est déjà installé"
    fi
}

change_default_shell() {
    local zsh_path

    zsh_path="$(command -v zsh)"

    log "Vérification du shell par défaut"

    if [ "$SHELL" != "$zsh_path" ]; then
        log "Changement du shell par défaut vers zsh"
        chsh -s "$zsh_path" "$USER"
    else
        log "zsh est déjà le shell par défaut"
    fi
}

main() {
    check_user
    check_dependencies
    install_omzsh
    change_default_shell

    log "Initialisation terminée"

	exec zsh
}

main