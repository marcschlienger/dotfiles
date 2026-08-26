# Keep PATH entries unique when nested shells source this file repeatedly.
typeset -U path PATH

# Set PATH so it includes user's private bin if it exists.
[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)

# Add the newest manually installed TeX Live, while preferring the stable
# macOS shim when MacTeX supplies it.
case "$OSTYPE" in
  darwin*)
    if [ -d /Library/TeX/texbin ]; then
      path=(/Library/TeX/texbin $path)
    else
      texlive_bins=(/usr/local/texlive/[0-9]*/bin/*-darwin(N))
      (( ${#texlive_bins} )) && path=("${texlive_bins[-1]}" $path)
      unset texlive_bins
    fi
    ;;
  linux*)
    texlive_bins=(/usr/local/texlive/[0-9]*/bin/*-linux(N))
    (( ${#texlive_bins} )) && path=("${texlive_bins[-1]}" $path)
    unset texlive_bins
    ;;
esac

# fzf
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --hidden --type f --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --hidden --type f --exclude .git'
fi
[ -n "${FZF_DEFAULT_COMMAND:-}" ] && \
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"

# lf
case "$OSTYPE" in
  darwin*)
    export OPENER=open
    ;;
  linux*)
    export OPENER=xdg-open
    ;;
esac

[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
