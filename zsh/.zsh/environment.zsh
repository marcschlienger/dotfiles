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
# ALTERNATE_EDITOR stays unset: the clients pass -a '' themselves, as Emacs
# Client.app's launcher does, so the behaviour lives with each caller rather
# than in the environment of every process.
#export EDITOR='emacsclient -t'
export EDITOR='nvim'
#export VISUAL='emacsclient -c -n'
export VISUAL="$EDITOR"

# pager
export PAGER='less -R'
