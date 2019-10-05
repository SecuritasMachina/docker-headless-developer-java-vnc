alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ls='ls -hFG'
alias l='ls -lF'
alias ll='ls -alF'
alias lt='ls -ltrF'
alias ll='ls -alF'
alias lls='ls -alSrF'
alias llt='ls -altrF'

alias tarc='tar cvf'
alias tarcz='tar czvf'
alias tarx='tar xvf'
alias tarxz='tar xvzf'

alias g='git'
alias less='less -R'
alias os='lsb_release -a'
alias vi='vim'

# Colorize directory listing
alias ls="ls -ph --color=auto"

#TODO  Colorize grep
#if echo hello|grep --color=auto l >/dev/null 2>&1; then
#  export GREP_OPTIONS="--color=auto" GREP_COLOR="1;31"
#fi

# Shell
export CLICOLOR="1"
if [ -f $HOME/.scripts/git-prompt.sh ]; then
  source $HOME/.scripts/git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE="1"
  #\u@\H
  export PS1="\[\033[40m\]\[\033[34m\][:\[\033[36m\]\w\$(__git_ps1 \" \[\033[35m\]{\[\033[32m\]%s\[\033[35m\]}\")\[\033[34m\] ]$\[\033[0m\] "
else
  export PS1="\[\033[40m\]\[\033[34m\][:\[\033[36m\]\w\[\033[34m\] ]$\[\033[0m\] "
fi
#export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=1;40:bd=34;40:cd=34;40:su=0;40:sg=0;40:tw=0;40:ow=0;40:"

if [ -f $HOME/include.source ]; then
  source $HOME/include.source
fi

# Git
source $HOME/.scripts/git-completion.sh

# Z
source $HOME/.scripts/z.sh

tmpfile=$(mktemp)
export TEMPDIR=$(mktemp -d)
export TEMP=$TEMPDIR
export TMP=$TEMPDIR

export PATH=$HOME/bin:$PATH

#Configure Proxy - don't set if root, ruins permissions
if [ -z "$http_proxy" ] && [ $EUID -ne 0 ] && [ $USER -ne "root" ]
then
	echo -e "\e[93m\e[1m !! Warning \e[44mhttp_proxy\e[49m environmental variable is not defined !!"
	echo -e "\e[0mCommands like git clone, wget etc. may not work depending on your container policy"
else
	git config --global http.proxy ${http_proxy}
fi


#Check if install needed
$HOME/.dockerDevTools/scripts/setupDevTools.sh

export PATH="$HOME/apps/tomcat/bin:$PATH"
export PATH="$HOME/apps/mysql/bin:$PATH"

#NPM
NPM_PACKAGES="${HOME}/.node"
export PATH="$NPM_PACKAGES/bin:$PATH"
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
export NODE_PATH="$HOME/.node/lib/node_modules:$NODE_PATH"

if [ -f "$HOME/.userProfile" ]
then
	echo "sourcing .userProfile"
        source $HOME/.userProfile
else
	echo ".userProfile missing, skipping load"
fi
