# Determine the operating system type
OS="$(uname)"

# Set PATH so it includes user's private bin if it exists.
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Set PATH so it includes the texlive installation
case "${OS}" in
  Darwin)
    export PATH=/usr/local/texlive/2025/bin/universal-darwin:$PATH
    ;;
  Linux)
    export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
    ;;
esac
export PATH="/Library/TeX/texbin:$PATH"

# fzf
case "${OS}" in
  Darwin)
    export FZF_DEFAULT_COMMAND='fd --hidden --type f'
    ;;
  Linux)
    export FZF_DEFAULT_COMMAND='fdfind --hidden --type f'
    ;;
esac
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
