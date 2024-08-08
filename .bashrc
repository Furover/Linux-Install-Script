#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi
eval "$(starship init bash)"
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi
if [ -f /usr/bin/fastfetch ]; then
	fastfetch
fi


# Load Angular CLI autocompletion.
source <(ng completion script)
