# .zshrc --- Personal configuration file for zsh.
#
# Copyright (C) 2013-2022 Marc Schlienger <marc.schlienger@psoteo.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software FOUNDATION, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Use ls colors
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Fix autosuggestions color for use with solarized color scheme
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# Use vim key bindings
bindkey -v
export KEYTIMEOUT=1

# Source configuration files
[ -f ~/.zsh/aliases.zsh ] && . ~/.zsh/aliases.zsh
[ -f ~/.zsh/completion.zsh ] && . ~/.zsh/completion.zsh
[ -f ~/.zsh/environment.zsh ] && . ~/.zsh/environment.zsh
[ -f ~/.zsh/options.zsh ] && . ~/.zsh/options.zsh
[ -f ~/.zsh/keys.zsh ] && . ~/.zsh/keys.zsh
[ -f ~/.zsh/restic.zsh ] && . ~/.zsh/restic.zsh

# Source fzf configuration
if [ -f ~/.fzf.zsh ]; then
   source ~/.fzf.zsh
else
  source <(fzf --zsh)
fi

# Source lf configuration
[ -f ~/.zsh/lf.zsh ] && . ~/.zsh/lf.zsh

# Source nnn configuration
[ -f ~/.zsh/nnn.zsh ] && . ~/.zsh/nnn.zsh

# Source ranger configuration
[ -f ~/.zsh/ranger.zsh ] && . ~/.zsh/ranger.zsh

# Source yazi configuration
[ -f ~/.zsh/yazi.zsh ] && . ~/.zsh/yazi.zsh

# Load plugins
[ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -d ~/.zsh/plugins/zsh-completions/zsh-completions.plugin.zsh ] && fpath=(~/.zsh/plugins/zsh-completions/src $fpath)
[ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && . ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load prompt
fpath=(~/.zsh $fpath)
autoload -Uz myprompt.zsh; myprompt.zsh

