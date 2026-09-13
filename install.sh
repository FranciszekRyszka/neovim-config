#!/usr/bin/env bash
# Bootstrap Neovima + konfiguracji na Ubuntu 24.04
set -euo pipefail

REPO="https://github.com/FranciszekRyszka/neovim-config.git"
CONFIG_DIR="$HOME/.config/nvim"

# Zależności: gcc dla parserów Treesitter, unzip dla Masona, ripgrep dla Telescope live_grep
sudo apt-get update -qq
sudo apt-get install -y -qq git curl unzip build-essential ripgrep
 
# npm dla bashls/yamlls/pyright – tylko jeśli go nie ma (apt-owy npm konfliktuje z Node z NodeSource)
command -v npm >/dev/null || sudo apt-get install -y -qq npm
 
# Neovim 0.11+ (apt daje 0.9.5)
if ! command -v nvim >/dev/null || ! nvim --version | grep -qE 'v0\.(1[1-9]|[2-9][0-9])'; then
  sudo apt-get remove -y -qq neovim || true
  sudo snap install nvim --classic
fi

# Wpisy w .bashrc – usuń stare (po znaczniku), dodaj aktualne
BASHRC="$HOME/.bashrc"
sed -i '/# nvim-config$/d' "$BASHRC"
cat >> "$BASHRC" <<'EOF'
export EDITOR=nvim # nvim-config
export SUDO_EDITOR=nvim # nvim-config
alias vi=nvim # nvim-config
EOF
source "$BASHRC"

# Konfiguracja
if [ -d "$CONFIG_DIR/.git" ]; then
  git -C "$CONFIG_DIR" pull --ff-only
else
  [ -d "$CONFIG_DIR" ] && mv "$CONFIG_DIR" "$CONFIG_DIR.bak.$(date +%s)"
  git clone "$REPO" "$CONFIG_DIR"
fi
 
# Instalacja wtyczek zgodnie z lazy-lock.json bez otwierania edytora
nvim --headless "+Lazy! restore" +qa
 
echo "Gotowe: $(nvim --version | head -1)"
