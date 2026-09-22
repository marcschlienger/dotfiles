# ls
if command -v lsd >/dev/null 2>&1; then
    alias l='lsd -lAh'
else
    alias l='ls -lAh'
fi
case "$OSTYPE" in
    darwin*) alias ls='ls -FGq' ;;
    *)       alias ls='ls -Fq --color=auto' ;;
esac
alias la='ls -Ah'
alias ll='ls -l'
alias lll='ll -Ah'
alias lc='ls -ltr .'

# cp, mv, rm
alias cp='nocorrect cp -iv'
alias cpd='cp -r'
alias mv='nocorrect mv -iv'
alias rm='nocorrect rm -v'
alias rmd='rm -r'

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

# diff
if diff --color=auto /dev/null /dev/null >/dev/null 2>&1; then
    alias diff='diff --color=always'
fi

# more or less
alias more='more -R'
alias less='less -R'

# kitty
alias s="kitten ssh"

# make a directory and cd into it
take () {
    if (( $# == 0 )); then
        print -u2 "usage: take DIRECTORY"
        return 2
    fi
    mkdir -p -- "$1" && cd -- "$1"
}

# jump to the root of a the current project
r () {
    local project_root
    project_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        print -u2 "not inside a Git worktree"
        return 1
    }
    cd -- "$project_root"
}

# jump to a projects root directory
jj () {
    local search_root="${1:-.}" selected
    selected=$(find "$search_root" -maxdepth 5 -type d -name .git -prune -print |
        sed 's|/\.git$||' |
        fzf --preview 'tree -L 2 -- {}')
    [[ -n "$selected" ]] && cd -- "$selected"
}

# create a temporary directory and jump to it
tmp () {
    local workspace_root="${TMPDIR:-/tmp}/workspaces" temp_dir
    mkdir -p -- "$workspace_root" || return
    temp_dir=$(mktemp -d "$workspace_root/XXXXXX") || return
    pushd -- "$temp_dir"
}

# emacs
# The clients carry -a '' as Emacs Client.app's launcher does, so every entry
# point behaves alike: connect to the server, and start one when none answers.
# A server started that way is not the one the service owns; while it holds the
# socket the service cannot start, and launchd respawns it every few seconds
# with a non-zero exit code until that server is killed. es shows that, and
# pgrep -fl 'Emacs --.*daemon' shows what is really running.
alias ec='emacsclient -c -n -a ""'
alias et='emacsclient -t -a ""'

# Save buffers before ek or er: service shutdown has no interactive save prompt.
case "$OSTYPE" in
    darwin*)
        ed()
        {
            local domain="gui/$UID"
            if ! launchctl print "$domain/gnu.emacs.daemon" >/dev/null 2>&1; then
                launchctl bootstrap "$domain" \
                    "$HOME/Library/LaunchAgents/gnu.emacs.daemon.plist" || return
            fi
            launchctl kickstart "$domain/gnu.emacs.daemon"
        }

        ek()
        {
            print -u2 -r -- "Stopping Emacs; buffers must already be saved (no save prompt)."
            launchctl bootout "gui/$UID/gnu.emacs.daemon"
        }

        er()
        {
            if launchctl print "gui/$UID/gnu.emacs.daemon" >/dev/null 2>&1; then
                ek || return
            fi
            ed
        }

        es()
        {
            launchctl print "gui/$UID/gnu.emacs.daemon"
        }
        ;;
    linux*)
        ed()
        {
            systemctl --user start emacs.service
        }

        ek()
        {
            print -u2 -r -- "Stopping Emacs; buffers must already be saved (no save prompt)."
            systemctl --user stop emacs.service
        }

        er()
        {
            print -u2 -r -- "Restarting Emacs; buffers must already be saved (no save prompt)."
            systemctl --user restart emacs.service
        }

        es()
        {
            systemctl --user status --no-pager emacs.service
        }
        ;;
esac

# ranger
alias rr=ranger_cd

# vim
alias vim=nvim

# extract
x()
{
    local archive="$1"
    if [[ -f "$archive" ]] ; then
        case "$archive" in
            *.tar|*.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.xz|*.tar.zst)
                        tar xf "$archive" ;;
            *.7z)       7z x -- "$archive" ;;
            *.bz2)      bunzip2 -- "$archive" ;;
            *.deb)      ar x "$archive" ;;
            *.gz)       gunzip -- "$archive" ;;
            *.rar)      unrar x "$archive" ;;
            *.zip)      unzip "$archive" ;;
            *.Z)        uncompress -- "$archive" ;;
            *)          echo "'$archive' cannot be extracted ..."
        esac
    else
        echo "'$archive' is not a valid file ..."
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
