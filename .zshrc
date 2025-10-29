# ------------------------------
# zsh
# ------------------------------
export LANG="en_GB.UTF-8"
export PROMPT="%n@%m %F{4}%~%F{sgr0} $ "

# ------------------------------
# Homebrew
# ------------------------------
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# ------------------------------
# OpenSSL
# ------------------------------
if ! command -v openssl &> /dev/null; then
    brew install openssl@1.1
fi

export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-L/opt/homebrew/opt/openssl@1.1/include"

# ------------------------------
# Node.js (volta)
# ------------------------------
if ! command -v volta &> /dev/null; then
    curl https://get.volta.sh | bash
fi

export VOLTA_FEATURE_PNPM=1
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias volta-install-base='volta install node npm pnpm'
alias volta-install-coding-agents='volta install @anthropic-ai/claude-code@latest @google/gemini-cli@latest @github/copilot@latest'

# ------------------------------
# Deno
# ------------------------------
export PATH="$HOME/.deno/bin:$PATH"

if ! command -v deno &> /dev/null; then
    curl -fsSL https://deno.land/install.sh | sh
fi

# ------------------------------
# Bun
# ------------------------------
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

# ------------------------------
# Python (uv)
# ------------------------------
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ------------------------------
# Go
# ------------------------------
if ! command -v go &> /dev/null; then
    brew install go
fi

export GOPATH="$(go env GOPATH)"
export GOBIN="$(go env GOBIN)"
export GOPKG="$GOPATH/pkg"
export GOSRC="$GOPATH/src"
export PATH="$GOBIN:$PATH"

# ------------------------------
# Rust
# ------------------------------
if ! command -v cargo &> /dev/null; then
    curl https://sh.rustup.rs -sSf | sh
fi

export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

# ------------------------------
# Haskell
# ------------------------------
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

if ! command -v ghcup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
fi

# ------------------------------
# zsh-completions
# ------------------------------
FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
FPATH="$HOME/.zsh-completions:$FPATH"

autoload -Uz compinit
compinit -u

zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
