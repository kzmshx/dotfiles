# Keep PATH / FPATH free of duplicates (first occurrence wins). zsh only dedups on array assignment
# (path=(...)), not on `export PATH=...`, so .zshrc reassigns path once at the end.
typeset -U path fpath

# PATH for tools that need to be available in non-interactive shells (GUI apps like Cursor)
# mise shims cover Node / pnpm there; interactive shells use `mise activate` in .zshrc
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Tokens for AI tools (available in GUI apps)
[ -f "$HOME/.gemini_token" ] && source "$HOME/.gemini_token"
