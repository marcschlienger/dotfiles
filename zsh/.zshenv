# Determine the operating system type
OS="$(uname)"

# Set PATH so it includes user's private bin if it exists.
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Set PATH so it includes the texlive installation
case "${OS}" in
  Darwin)
    [ -d /usr/local/texlive/2025/bin/universal-darwin ] && \
      export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
    [ -d /Library/TeX/texbin ] && export PATH="/Library/TeX/texbin:$PATH"
    ;;
  Linux)
    [ -d /usr/local/texlive/2025/bin/x86_64-linux ] && \
      export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
    ;;
esac

# fzf
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --hidden --type f'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --hidden --type f'
fi
[ -n "${FZF_DEFAULT_COMMAND:-}" ] && \
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"

# lf
case "${OS}" in
  Darwin)
    export OPENER=open
    ;;
  Linux)
    export OPENER=mimeopen
    ;;
esac

[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
