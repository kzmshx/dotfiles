export LANG="en_GB.UTF-8"
export PROMPT="%n@%m %F{4}%~%F{sgr0} $ "


# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"



# zsh-completions
FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
FPATH="$HOME/.zsh-completions:$FPATH"

autoload -Uz compinit
compinit -u

zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''


# binutils
export PATH="/opt/homebrew/Cellar/binutils/2.37/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/Cellar/binutils/2.37/lib"
export CPPFLAGS="-I/opt/homebrew/Cellar/binutils/2.37/include"


# go
export GOPATH="$(go env GOPATH)"
export GOBIN="$(go env GOBIN)"
export GOPKG="$GOPATH/pkg"
export GOSRC="$GOPATH/src"
export PATH="$GOBIN:$PATH"


# nodejs
export PATH="$HOME/.nodebrew/current/bin:$PATH"


# python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init --path)"


# rust
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"


# kzmsh/compete
export PATH="$HOME/go/src/github.com/kzmsh/compete/bin:$PATH"
