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

    export VOLTA_FEATURE_PNPM=1
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"

    export PNPM_HOME="$HOME/Library/pnpm"
    case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    alias volta-update-base='volta install node npm pnpm'
    alias volta-update-tools='volta install @anthropic-ai/claude-code@latest @google/gemini-cli@latest @github/copilot@latest'
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

    export CARGO_HOME="$HOME/.cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
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
