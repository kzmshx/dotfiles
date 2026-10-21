export LANG="en_GB.UTF-8"
export PROMPT="%n@%m %F{4}%~%F{sgr0} $ "

function setup_brew() {
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

function setup_openssl() {
    if ! command -v openssl &>/dev/null; then
        brew install openssl@1.1
    fi
    export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
    export CPPFLAGS="-L/opt/homebrew/opt/openssl@1.1/include"
}

function setup_volta() {
    if ! command -v volta &>/dev/null; then
        curl https://get.volta.sh | bash
    fi

    # VOLTA_HOME and PATH are set in .zshenv
    export VOLTA_FEATURE_PNPM=1

    export PNPM_HOME="$HOME/Library/pnpm"
    case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # Stay on pnpm 11: Volta cannot launch pnpm 12 (no bin/pnpm.cjs)
    alias volta-update-base='volta install node npm pnpm@11'
}

function setup_deno() {
    export PATH="$HOME/.deno/bin:$PATH"

    if ! command -v deno &>/dev/null; then
        curl -fsSL https://deno.land/install.sh | sh
    fi
}

function setup_bun() {
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    if ! command -v bun &>/dev/null; then
        curl -fsSL https://bun.sh/install | bash
    fi
}

function setup_uv() {
    if ! command -v uv &>/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

function setup_go() {
    if ! command -v go &>/dev/null; then
        brew install go
    fi

    export GOPATH="$(go env GOPATH)"
    export GOBIN="$(go env GOBIN)"
    export GOPKG="$GOPATH/pkg"
    export GOSRC="$GOPATH/src"
    export PATH="$GOBIN:$PATH"
}

function setup_cargo() {
    if ! command -v cargo &>/dev/null; then
        curl https://sh.rustup.rs -sSf | sh
    fi

    # CARGO_HOME and PATH are set in .zshenv via cargo env
}

function setup_ghcup() {
    [ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

    if ! command -v ghcup &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
    fi
}

function setup_gh() {
    if ! command -v gh &>/dev/null; then
        brew install gh
    fi
}

function setup_gh_auth() {
    if ! gh auth status &>/dev/null; then
        gh auth login
    fi

    export GITHUB_TOKEN=$(gh auth token)
}

function setup_gcloud() {
    GCLOUD_DIR="$HOME/tools/google-cloud-sdk"
    if [ ! -d "$GCLOUD_DIR" ]; then
        mkdir -p "$HOME/tools"
        cd "$HOME/tools"
        curl https://sdk.cloud.google.com | bash
        cd -
    fi

    export PATH="$GCLOUD_DIR/bin:$PATH"
    [ -f "$GCLOUD_DIR/path.zsh.inc" ] && source "$GCLOUD_DIR/path.zsh.inc"
    [ -f "$GCLOUD_DIR/completion.zsh.inc" ] && source "$GCLOUD_DIR/completion.zsh.inc"
}

function setup_tfenv() {
    if ! command -v tfenv &>/dev/null; then
        brew install tfenv
    fi
}

function setup_zsh_completions() {
    export FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
    export FPATH="$HOME/.zsh-completions:$FPATH"

    autoload -Uz compinit
    compinit -u

    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' format '%B%d%b'
    zstyle ':completion:*:warnings' format 'No matches for: %d'
    zstyle ':completion:*' group-name ''
}

function setup_aliases() {
    alias cd-atoms='cd $HOME/go/src/github.com/kzmshx/atoms'
}

# ------------------------------
# Periodic updates: run `update-all` monthly, or when a vulnerability hits the news
# ------------------------------
UPDATE_ALL_STAMP="$HOME/.cache/update-all.last"

function update-all() {
    echo "==> Homebrew (ca-certificates, go, git, gh, rustup, tfenv, claude-code, ...)"
    brew update && brew upgrade

    echo "==> Volta: Node LTS / npm / pnpm"
    volta-update-base
    # Global packages stay pinned to the Node they were installed with; reinstall to repin to the new default
    local pkgs=(${(f)"$(volta list all --format=plain | awk '$1 == "package" {print $2}' | sed 's/@[^@]*$//' | grep -vx pnpm)"})
    (( ${#pkgs} )) && volta install "${pkgs[@]}"

    echo "==> uv"
    uv self update && uv tool upgrade --all

    echo "==> Rust"
    rustup update

    echo "==> Deno / Bun"
    deno upgrade
    bun upgrade

    echo "==> gcloud"
    gcloud components update --quiet

    echo "==> macOS (list only; apply from System Settings)"
    softwareupdate --list

    check-emudhra-workaround

    mkdir -p "${UPDATE_ALL_STAMP:h}" && touch "$UPDATE_ALL_STAMP"
}

# eMudhra workaround (2026-10-21): once Apple drops the two roots from /etc/ssl/cert.pem,
# CURL_CA_BUNDLE below and git's http.sslCAInfo can be removed
function check-emudhra-workaround() {
    if grep -q -e "AAA Certificate Services" -e "emSign ECC Root CA - G3" /etc/ssl/cert.pem; then
        echo "==> eMudhra: /etc/ssl/cert.pem is not fixed yet; keep CURL_CA_BUNDLE and http.sslCAInfo"
    else
        echo "==> eMudhra: /etc/ssl/cert.pem is fixed. Remove CURL_CA_BUNDLE from .zshrc and run:"
        echo "    git config --global --unset http.sslCAInfo"
    fi
}

function remind-update-all() {
    [[ -o interactive && -t 1 ]] || return
    if [[ ! -f "$UPDATE_ALL_STAMP" || -n $(find "$UPDATE_ALL_STAMP" -mtime +30 2>/dev/null) ]]; then
        echo "update-all has not been run for 30+ days"
    fi
}

# ------------------------------
# If SSH_CONNECTION is not empty, source the claude_token file and skip the rest of the script
# ------------------------------
if [[ -n "$SSH_CONNECTION" ]]; then
    echo "SSH_CONNECTION detected"

    # Load the Claude token
    source ~/.claude_token

    # Setup the environment
    setup_brew
    setup_openssl
    setup_volta
    setup_deno
    setup_bun
    setup_uv
    setup_go
    setup_cargo
    setup_ghcup
    setup_gh
    setup_gcloud
    setup_tfenv
    setup_zsh_completions
    setup_aliases

    return
fi

# Setup the environment
setup_brew
setup_openssl
setup_volta
setup_deno
setup_bun
setup_uv
setup_go
setup_cargo
setup_ghcup
setup_gh
setup_gh_auth
setup_gcloud
setup_tfenv
setup_zsh_completions
setup_aliases
remind-update-all

# moonbit
export PATH="$HOME/.moon/bin:$PATH"

# moonbit
export PATH="$HOME/.moon/bin:$PATH"

# bun completions
[ -s "/Users/kzmshx/.bun/_bun" ] && source "/Users/kzmshx/.bun/_bun"


# Added by Antigravity CLI installer
export PATH="/Users/kzmsh/.local/bin:$PATH"

# eMudhra workaround (2026-10-21): /etc/ssl/cert.pem still trusts the compromised chain, so point /usr/bin/curl at Homebrew's CA bundle.
# Run check-emudhra-workaround to see whether it can be removed
export CURL_CA_BUNDLE=/opt/homebrew/etc/ca-certificates/cert.pem
