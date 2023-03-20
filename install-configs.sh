#!/bin/bash

# Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

# Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

# Help function
function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT -t [full, ctf]${NORM}"\\n
  echo "${REV}-t${NORM}  --Choose between 'full' or 'ctf' VM installs."
  echo -e "${REV}-h${NORM}  --Displays this help message and exits."\\n
  echo -e "Example: ${BOLD}$SCRIPT -t ctf"\\n
  exit 1
}

function check_if_success () {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Something went wrong. Stopping here so you can check the error."
        exit
    fi
}

# Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

while getopts 'h:t:' flag; do
    case "$flag" in
        h) echo "usage";;
        
        t) type=${OPTARG};;
    esac
done

if [ -v "$type" ]; then
    echo "The -t flag is required. Needs to be one of the following: ['full', 'ctf']"
    exit 1
fi


if [[ ! $type == 'full' ]] && [[ ! $type == 'ctf' ]]; then
    echo "the -t flag needs to be either 'full' or 'ctf'."
    exit 1
fi

echo "VM type: $type";

if [[ $type == 'full' ]]; then
    echo -e \\n"Installing full vim config"
    # vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-vimrc)
    vim_rc=$(cat ./dotfiles/full-vimrc)
    echo "$vim_rc" > ~/.vimrc

    echo -e \\n"Installing full shell aliases"
    # zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-aliases)
    zsh_rc=$(cat ./dotfiles/full-aliases)
    echo "$zsh_rc" >> ~/.zshrc
    echo "$zsh_rc" >> ~/.bash_aliases

    echo -e \\n"Installing full tmux.conf"
    # tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-tmux.conf)
    tmux_conf=$(cat ./dotfiles/full-tmux.conf)
    echo "$tmux_conf" > ~/.tmux.conf

    echo -e \\n"Installing VIM plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_if_success

    echo -e \\n"Installing tmux themes"
    sudo mkdir /opt/tmux && cd /opt/tmux
    check_if_success
    sudo git clone https://github.com/wfxr/tmux-power.git
    cd ~
fi


if [[ $type == 'ctf' ]]; then
    echo -e \\n"Installing CTF vim config"
    # vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-vimrc)
    vim_rc=$(cat ./dotfiles/ctf-vimrc)
    echo "$vim_rc" > ~/.vimrc

    echo -e \\n"Installing CTF shell aliases"
    # zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-aliases)
    zsh_rc=$(cat ./dotfiles/ctf-aliases)
    echo "$zsh_rc" >> ~/.zshrc
    echo "$zsh_rc" >> ~/.bash_aliases

    echo -e \\n"Installing CTF tmux.conf"
    # tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-tmux.conf)
    tmux_conf=$(cat ./dotfiles/ctf-tmux.conf)
    echo "$tmux_conf" > ~/.tmux.conf
fi