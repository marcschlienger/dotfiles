# ls
alias l='lsd -lAh'
alias ls='ls -Fq --color'
alias la='ls -Ah'
alias ll='ls -l'
alias lll='ll -Ah'
alias lc='ls -ltr $(pwd)'

# cp, mv, rm
alias cp='nocorrect cp -iv'
alias cpd='cp -r'
alias mv='nocorrect mv -iv'
alias rm='nocorrect rm -v'
alias rmd'rm -r'

# history
alias h='history -20'

# cd
alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# make a directory and cd into it
take () {
    mkdir -p "$1" && cd "$1"
}

# jump to the root of a the current project
r () {
    cd "$(git rev-parse --show-toplevel 2>/dev/null)"
}

# jump to a projects root directory
jj () {
    cd "${1:-.}/$(find . -maxdepth 5 -type d -name .git | sed 's|/.git$||' | fzf --preview 'tree -L 2 ./{}')"
}

# create a temporary directory and jump to it
tmp () {
    r="/tmp/workspaces/$(xxd -l3 -ps /dev/urandom)"
    mkdir -p "$r" && pushd "$r"
}

# bat
alias bat='batcat --theme ansi'

# emacsclient
alias ec='emacsclient -c -n -a ""'

# ranger
alias rr=ranger_cd

# vim
alias vim=nvim

# extract
x()
{
    if [[ -f $1 ]] ; then
        case $1 in
            *.7z)       7z x $1 ;;
            *.bz2)      bunzip2 $1 ;;
            *.deb)      ar x $1 ;;
            *.gz)       gunzip $1 ;;
            *.rar)      unrar xjf $1 ;;
            *.tar)      tar xf $1 ;;
            *.tar.bz2)  tar xjf $1 ;;
            *.tar.gz)   tar xzf $1 ;;
            *.tar.xz)   tar xf $1 ;;
            *.tar.zst)  unzstd $1 ;;
            *.tbz2)     tar xjf $1 ;;
            *.tgz)      tar xzf $1 ;;
            *.zip)      unzip $1 ;;
            *.Z)        uncompress $1 ;;
            *)          echo "'$1' cannot be extracted ..."
        esac
    else
        echo "'$1' is not a valid file ..."
    fi
}

# exit the shell
alias q='exit'

# global aliases
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'

# tmux: fix tmux color issues
alias tmux='tmux -2'

# git
alias gs='git status'
alias ga='git add'
alias gph='git push'
alias gpho='git push origin'
alias gtd='git tag --delete'
alias gtdo='git tag --delete origin'
alias gb='git branch '
alias gbr='git branch -r'
alias gplo='git pull origin'
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gl='git log'
alias gr='git remote'
alias grs='git remote show'
alias glo='git log --pretty="oneline"'
alias glol='git log --graph --oneline --decorate'

# execute file names
alias -s c=vim
alias -s cc=vim
alias -s cpp=vim
alias -s h=vim
alias -s hh=vim
alias -s hpp=vim
alias -s tex=vim
alias -s txt=vim

alias -s html='firefox'
alias -s com='firefox'
alias -s de='firefox'
alias -s net='firefox'
alias -s org='firefox'

alias -s dvi='zathura'
alias -s pdf='zathura'
alias -s ps='zathura'

