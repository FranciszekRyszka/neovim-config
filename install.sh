#!/usr/bin/env bash
# Bootstrap Neovima + konfiguracji na Ubuntu 24.04
set -euo pipefail

CONFIG_DIR="$HOME/.config/nvim"

# Zależności: gcc dla parserów Treesitter, npm dla bashls/yamlls/pyright, unzip dla Masona
sudo apt-get update -qq
sudo apt-get install -y -qq git curl unzip build-essential npm ripgrep

# Neovim 0.11+ (apt daje 0.9.5)
if ! command -v nvim >/dev/null || ! nvim --version | grep -qE 'v0\.(1[1-9]|[2-9][0-9])'; then
  sudo apt-get remove -y -qq neovim || true
  sudo snap install nvim --classic
  hash -r
fi

# Konfiguracja
if [ -d "$CONFIG_DIR/.git" ]; then
  git -C "$CONFIG_DIR" pull --ff-only
else
  [ -d "$CONFIG_DIR" ] && mv "$CONFIG_DIR" "$CONFIG_DIR.bak.$(date +%s)"
fi

# Instalacja wtyczek zgodnie z lazy-lock.json bez otwierania edytora
nvim --headless "+Lazy! restore" +qa

echo "Gotowe: $(nvim --version | head -1)"
