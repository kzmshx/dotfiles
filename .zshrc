# ------------------------------
# zsh
# ------------------------------
export LANG="en_GB.UTF-8"
export PROMPT="%n@%m %F{4}%~%F{sgr0} $ "

# ------------------------------
# Homebrew
# ------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# ------------------------------
# OpenSSL
# ------------------------------
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-L/opt/homebrew/opt/openssl@1.1/include"

# ------------------------------
# Node.js (Volta)
# ------------------------------
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# ------------------------------
# Bun
# ------------------------------
# bun completions
[ -s "/Users/kzmsh/.bun/_bun" ] && source "/Users/kzmsh/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ------------------------------
# Python
# ------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init --path)"

# Created by `pipx` on 2023-05-29 12:59:49
export PATH="$PATH:/Users/kzmsh/.local/bin"

# ------------------------------
# Ruby
# ------------------------------
eval "$(rbenv init - zsh)"

# ------------------------------
# Go
# ------------------------------
export GOPATH="$(go env GOPATH)"
export GOBIN="$(go env GOBIN)"
export GOPKG="$GOPATH/pkg"
export GOSRC="$GOPATH/src"
export PATH="$GOBIN:$PATH"

# ------------------------------
# Rust
# ------------------------------
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

# ------------------------------
# Haskell
# ------------------------------
[ -f "/Users/kzmsh/.ghcup/env" ] && source "/Users/kzmsh/.ghcup/env"

# ------------------------------
# Terraform
# ------------------------------
# tfenv
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/Cellar/tfenv/3.0.0/versions/1.5.7/terraform terraform

# ------------------------------
# Google Cloud SDK
# ------------------------------
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kzmsh/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kzmsh/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kzmsh/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kzmsh/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

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
