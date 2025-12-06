# maximum size of the directory stack
export DIRSTACKSIZE=20

# files to be ignored by completion
export FIGNORE='.o'

# maximum number of events stored in the internal history and the histfile
export HISTSIZE=1024

# histfile
export HISTFILE=${HOME}/.zsh/histfile

# maximum number of events stored in histfile
export SAVEHIST=1024

# editor
#export EDITOR=nvim
#export VISUAL=${EDITOR}
export ALTERNATE_EDITOR=""
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -c -n'

# pager
export PAGER='less -R'
