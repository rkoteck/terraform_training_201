bash_prompt() {
  local NONE="\[\033[0m\]"    # unsets color to term's fg color
  local Y="\[\033[0;33m\]"    # yellow
  local EMY="\[\033[1;33m\]"
  local EMW="\[\033[1;37m\]"
  PS1="$EMW\u:$EMY\w$Y \$ ${NONE}"
  PS4='$ '
}

bash_prompt
unset bash_prompt

shopt -s checkwinsize
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s globstar

export MANPATH=/home/linuxbrew/.linuxbrew/man:$MANPATH
export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
export PATH=/home/linuxbrew/.linuxbrew/sbin:$PATH
export PATH="$HOME/bin:$HOME/bin/$(uname -s):$PATH"

export CLICOLOR=1
export HISTCONTROL="ignoredups"
export HISTSIZE="2000"
export EDITOR="vim"
export VISUAL="vim"
export PAGER=less
export BLOCKSIZE=K
export LC_CTYPE=en_US.UTF-8
export LESS="-X -M -E -R"
export TERM=xterm-256color

export LS_COLORS
eval $(dircolors ~/.dircolors)

export AWS_DEFAULT_REGION="us-west-2"

alias ls="gls -ohF --color=auto"
alias grep="grep --color=auto"

. /home/linuxbrew/.linuxbrew/etc/bash_completion
. .terraform-completion
. .aws_credentials
