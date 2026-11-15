#!/bin/zsh
# bootstrap.sh: set up a new Mac, then link the dotfiles with init.sh.
# Installs Homebrew and the tools .zshrc expects. Anything already installed is skipped, so it is safe to re-run.
set -euo pipefail

SCRIPT_DIR=${0:A:h}

header() { print -P "%F{4}==> $1%f" }

# True when the tool is neither on PATH nor at the path its installer uses
# (before the dotfiles are linked, ~/.deno/bin and the like are not on PATH yet)
missing() { ! command -v "$1" &>/dev/null && [[ ! -x $2 ]] }

# Homebrew first: init.sh needs jq from the Brewfile
if missing brew /opt/homebrew/bin/brew; then
    header "Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

header "Brewfile"
brew bundle --file="$SCRIPT_DIR/Brewfile"

# ~/.zshrc is this repo's file, so installers are told not to edit shell startup files
if missing deno "$HOME/.deno/bin/deno"; then
    header "Deno"
    curl -fsSL https://deno.land/install.sh | sh -s -- -y --no-modify-path
fi
if missing bun "$HOME/.bun/bin/bun"; then
    header "Bun"
    # No opt-out flag: the installer edits the rc file of the shell named in $SHELL, and leaves sh alone
    curl -fsSL https://bun.sh/install | SHELL=/bin/sh bash
fi
if missing uv "$HOME/.local/bin/uv"; then
    header "uv"
    curl -LsSf https://astral.sh/uv/install.sh | UV_NO_MODIFY_PATH=1 sh
fi
if missing rustup "$HOME/.cargo/bin/rustup"; then
    header "Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
if missing ghcup "$HOME/.ghcup/bin/ghcup"; then
    header "GHCup"
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 sh
fi
if [[ ! -d $HOME/tools/google-cloud-sdk ]]; then
    header "gcloud"
    mkdir -p "$HOME/tools"
    curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME/tools"
fi

if ! gh auth token &>/dev/null; then
    header "GitHub CLI login"
    gh auth login
fi

header "Links"
"$SCRIPT_DIR/init.sh"

# After the links: mise reads ~/.config/mise/config.toml
header "mise: Node / pnpm / global npm packages"
mise install
