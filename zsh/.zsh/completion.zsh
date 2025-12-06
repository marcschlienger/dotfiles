zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' max-errors 2 not-numeric
zstyle ':completion:*' prompt '%e'

autoload -Uz compinit; compinit
autoload zmv 

