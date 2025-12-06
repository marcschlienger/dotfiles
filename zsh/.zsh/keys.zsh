# use vi mode for zle
bindkey -v

# key bindings
bindkey '^[[5~' history-beginning-search-backward
bindkey '^[[6~' history-beginning-search-forward
bindkey -s '^o' 'lfcd\n'

