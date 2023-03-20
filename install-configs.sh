#!/bin/bash
function check_if_success () {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Something went wrong. Stopping here so you can check the error."
        exit
    fi
}

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
    echo "Full vim config"
    vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-vimrc)
    echo "$vim_rc" > ~/.vimrc

    echo "Full shell aliases"
    zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-aliases)
    echo "$zsh_rc" >> ~/.zshrc
    echo "$zsh_rc" >> ~/.bash_aliases

    echo "Full tmux.conf"
    tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-tmux.conf)
    echo "$tmux_conf" > ~/.tmux.conf

    echo "Install VIM plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_if_success

    echo "Install tmux themes"
    sudo mkdir /opt/tmux && cd /opt/tmux
    check_if_success
    sudo git clone https://github.com/wfxr/tmux-power.git
    cd ~
fi


if [[ $type == 'ctf' ]]; then
    echo "CTF vim config"
    vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-vimrc)
    echo "$vim_rc" > ~/.vimrc

    echo "CTF shell aliases"
    zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-aliases)
    echo "$zsh_rc" >> ~/.zshrc
    echo "$zsh_rc" >> ~/.bash_aliases

    echo "CTF tmux.conf"
    tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-tmux.conf)
    echo "$tmux_conf" > ~/.tmux.conf
fi