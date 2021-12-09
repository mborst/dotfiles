#------------------------------------------------------------------#
# File:     .zshrc   ZSH resource file                             #
#------------------------------------------------------------------#
# Assumess ZDOTDIR is set in .zshenv                               #

ZDOTDIR="${${(%):-%x}:P:h}"

fpath=(
  "$ZDOTDIR/functions"
  "$ZDOTDIR/completion"
  "/usr/local/share/zsh-completions"
  $fpath
)

#------------------------------
# History
#------------------------------
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
#setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
#setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

#------------------------------
# Environment & Sourcing
#------------------------------
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.yarn/bin"
  "$HOME/code/go/bin"
  "/usr/local/opt/fzf/bin"
  "/usr/local/opt/gnu-sed/libexec/gnubin"
  "/usr/local/opt/python"
  "/usr/local/opt/python@2/bin"
  "/usr/local/opt/python/bin"
  "/usr/local/opt/coreutils/libexec/gnubin"
  "/usr/local/opt/findutils/libexec/gnubin"
  "/usr/local/opt/openssl/bin"
  "/usr/local/opt/gawk/libexec/gnubin"
  "/usr/local/opt/gnu-getopt/libexec/gnubin"
  "/usr/local/opt/gnu-indent/libexec/gnubin"
  "/usr/local/opt/gnu-tar/libexec/gnubin"
  "/usr/local/opt/gnu-sed/libexec/gnubin"
  "/usr/local/opt/grep/libexec/gnubin"
  $path
)

manpath=(
  "/usr/local/opt/coreutils/libexec/gnuman"
  "/usr/local/opt/findutils/libexec/gnuman"
  "/usr/local/opt/gawk/libexec/gnuman"
  "/usr/local/opt/gnu-getopt/libexec/gnuman"
  "/usr/local/opt/gnu-indent/libexec/gnuman"
  "/usr/local/opt/gnu-sed/libexec/gnuman"
  "/usr/local/opt/gnu-tar/libexec/gnuman"
  "/usr/local/opt/grep/libexec/gnuman"
  "/usr/local/share/man"
  "/usr/share/man"
)

source "$ZDOTDIR/aliases"
source "$ZDOTDIR/git-shortcuts"
source "$ZDOTDIR/k8s-aliases"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export EDITOR=nvim

# Make gpg more reliable
export GPG_TTY=$(tty)

export "GOPATH=${HOME}/go"

source "$ZDOTDIR/private"

#-----------------------------
# Dircolors
#-----------------------------
LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS

#------------------------------
# Features
#------------------------------
setopt AUTO_CD
setopt NONOMATCH
setopt interactivecomments

#------------------------------
# ShellFuncs
#------------------------------
# -- coloured manuals
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

#------------------------------
# Keybindings
#------------------------------
# Updates editor information when the keymap changes.
function zle-line-init zle-keymap-select() {
  zle reset-prompt
  zle -R
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N edit-command-line

zle-keymap-select () {
  if [ $KEYMAP = vicmd ]; then
    # the command mode for vi
    echo -ne "\e[2 q"
  else
    # the insert mode for vi
    echo -ne "\e[4 q"
  fi
}

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -v
bindkey -M vicmd 'v' edit-command-line
# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey "^K" history-beginning-search-backward

bindkey -M viins 'jj' vi-cmd-mode # escape insert mode with jj
KEYTIMEOUT=30

#------------------------------
# Comp stuff
#------------------------------
zmodload zsh/complist
autoload -Uz compinit
compinit
zstyle :compinstall filename '${HOME}/.zshrc'

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always

echo 'complete -F __start_kubectl k' >>~/.zshrc
#------------------------------
# Prompt
#------------------------------
autoload -U colors && colors
autoload -U promptinit; promptinit
prompt pure
PURE_GIT_PULL=0

#------------------------------
# FZF config
#------------------------------
# Auto-completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null
# Key bindings
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

source "${ZDOTDIR}/fzf-functions"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

export FZF_DEFAULT_OPTS='--height 30% --layout=reverse'

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
