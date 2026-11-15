export LANG="en_GB.UTF-8"
export PROMPT="%n@%m %F{4}%~%F{sgr0} $ "

# History: macOS defaults are HISTSIZE=2000 / SAVEHIST=1000 (/etc/zshrc)
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt share_history       # write each command at once and read the other shells' commands
setopt extended_history    # record start time and duration
setopt hist_ignore_dups    # skip a command identical to the previous one
setopt hist_ignore_space   # skip commands starting with a space (for one-off secrets)
setopt hist_reduce_blanks

# PATH and settings only. Tools are installed by bootstrap.sh, not when a shell opens.

function setup_brew() {
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
}

function setup_mise() {
    command -v mise &>/dev/null && eval "$(mise activate zsh)"

    # Global bin for `pnpm add -g` (commitlint, textlint, ...)
    export PNPM_HOME="$HOME/Library/pnpm"
    export PATH="$PNPM_HOME:$PATH"
}

function setup_deno() {
    export PATH="$HOME/.deno/bin:$PATH"
}

function setup_bun() {
    # Completions are sourced in setup_zsh_completions: _bun runs its own compinit when loaded before it
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
}

function setup_go() {
    # Fixed instead of `go env` (a fork per shell); keep in sync with `go env -w GOBIN=...`
    export GOPATH="$HOME/go"
    export GOBIN="$GOPATH/bin"
    export GOPKG="$GOPATH/pkg"
    export GOSRC="$GOPATH/src"
    export PATH="$GOBIN:$PATH"
}

function setup_ghcup() {
    [ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
}

function setup_gcloud() {
    GCLOUD_DIR="$HOME/tools/google-cloud-sdk"
    [ -d "$GCLOUD_DIR" ] || return

    export PATH="$GCLOUD_DIR/bin:$PATH"
    [ -f "$GCLOUD_DIR/path.zsh.inc" ] && source "$GCLOUD_DIR/path.zsh.inc"
    # Completions are sourced in setup_zsh_completions: completion.zsh.inc runs compinit itself when loaded before it
}

function setup_zsh_completions() {
    export FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$FPATH"
    export FPATH="$HOME/.zsh-completions:$FPATH"

    # Rebuild the dump (fpath scan + security check) at most once a day; otherwise load it as is.
    # Completions added in between show up on the next rebuild, or run `rm ~/.zcompdump` to force it.
    autoload -Uz compinit
    local -a stale=(${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24))
    if (( ${#stale} )); then
        compinit -u
    else
        compinit -C -u
    fi

    # Scripts that register with compdef / complete must come after compinit, which resets the registrations
    [[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
    [[ -f "$GCLOUD_DIR/completion.zsh.inc" ]] && source "$GCLOUD_DIR/completion.zsh.inc"

    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' format '%B%d%b'
    zstyle ':completion:*:warnings' format 'No matches for: %d'
    zstyle ':completion:*' group-name ''
}

function setup_aliases() {
    alias cd-atoms='cd $HOME/go/src/github.com/kzmshx/atoms'
}

# ------------------------------
# Periodic updates: run `u` (bin/u) monthly, or when a vulnerability hits the news
# ------------------------------
function remind-u() {
    [[ -o interactive && -t 1 ]] || return
    local stamp="$HOME/.cache/u.last"
    if [[ ! -f "$stamp" || -n $(find "$stamp" -mtime +30 2>/dev/null) ]]; then
        echo "u has not been run for 30+ days"
    fi
}

# ------------------------------
# If SSH_CONNECTION is not empty, source the claude_token file and skip the rest of the script
# ------------------------------
if [[ -n "$SSH_CONNECTION" ]]; then
    echo "SSH_CONNECTION detected"

    # Load the Claude token
    [[ -f ~/.claude_token ]] && source ~/.claude_token

    # Setup the environment
    setup_brew
    setup_mise
    setup_deno
    setup_bun
    setup_go
    setup_ghcup
    setup_gcloud
    setup_zsh_completions
    setup_aliases

    return
fi

# Setup the environment
setup_brew
setup_mise
setup_deno
setup_bun
setup_go
setup_ghcup
setup_gcloud
setup_zsh_completions
setup_aliases
remind-u

# moonbit
export PATH="$HOME/.moon/bin:$PATH"

# Move ~/.local/bin (also added in .zshenv) back to the front: the setup_* above prepend in front of it,
# and its stack (stack upgrade) and python3.12 (uv) are newer than the ghcup / Homebrew ones.
# Assigning the arrays also drops the duplicates (typeset -U in .zshenv).
path=("$HOME/.local/bin" $path)
fpath=($fpath)

# eMudhra workaround (2026-10-21): /etc/ssl/cert.pem still trusts the compromised chain, so point /usr/bin/curl at Homebrew's CA bundle.
# `u` reports whether it can be removed
export CURL_CA_BUNDLE=/opt/homebrew/etc/ca-certificates/cert.pem
