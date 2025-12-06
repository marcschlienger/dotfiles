# Set PATH so it includes user's private bin if it exists.
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Set PATH so it includes the texlive installation
#export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

# Set PATH so it includes the lua language server
#export PATH="/home/marc/.local/src/lua-language-server/build/bin:$PATH"

# fzf
export FZF_DEFAULT_COMMAND='fdfind --hidden --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"

# lf
#export OPENER=mimeopen

# QT color themes
#export QT_QPA_PLATFORMTHEME=qt5ct
