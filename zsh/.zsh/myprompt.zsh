autoload -U colors && colors

##############################################################################
# vcs info
##############################################################################
# load vcs_info
autoload -Uz vcs_info

# to be able to use '${vcs_info_msg_0_}' directly in the prompt
setopt PROMPT_SUBST

# common settings
zstyle ':vcs_info:*' enable git

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true

zstyle ':vcs_info:*' actionformats ' on %B%F{5} %b (%a) [%u%c%m] '
zstyle ':vcs_info:*' formats ' on %B%F{5} %b [%u%c%m] '

# git settings
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '!!'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked 
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] \
      && git status --porcelain | grep -m 1 '^??' &>/dev/null
  then
    hook_com[misc]='?'
  fi
}

# necessary to use vcs_info in the prompt
precmd () { vcs_info }

##############################################################################
# prompt
##############################################################################
PROMPT='%B%F{2}%m%f%b'
PROMPT+=' in '
PROMPT+='%B%F{4}%2~%f%b'
PROMPT+='${vcs_info_msg_0_}%f%b'
PROMPT+='
%(?.%B%F{3}>> %f%b.%B%F{1}>> %f%b)'

