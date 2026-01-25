# PATH for tools that need to be available in non-interactive shells (GUI apps like Cursor)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Cargo
. "$HOME/.cargo/env"

# Tokens for AI tools (available in GUI apps)
[ -f "$HOME/.gemini_token" ] && source "$HOME/.gemini_token"
