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
    echo "\nFull vim config"
    # vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-vimrc)
    vim_rc=$(cat ./dotfiles/full-vimrc)
    echo "$vim_rc" > ~/.vimrc

    echo "\nFull shell aliases"
    # zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-aliases)
    zsh_rc=$(cat ./dotfiles/full-aliases)
    echo "$zsh_rc" >> ~/.zshrc
    echo "$zsh_rc" >> ~/.bash_aliases

    echo "\nFull tmux.conf"
    # tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/full-tmux.conf)
    tmux_conf=$(cat ./dotfiles/full-tmux.conf)
    echo "$tmux_conf" > ~/.tmux.conf

    echo "\nInstall VIM plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_if_success

    echo "\nInstall tmux themes"
    sudo mkdir /opt/tmux && cd /opt/tmux
    check_if_success
    sudo git clone https://github.com/wfxr/tmux-power.git
    cd ~
fi


if [[ $type == 'ctf' ]]; then
    echo "\nCTF vim config"
    # vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-vimrc)
    vim_rc=$(cat ./dotfiles/ctf-vimrc)
    echo "$vim_rc" > ~/.vimrc

    echo "\nCTF shell aliases"
    # zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-aliases)
    zsh_rc=$(cat ./dotfiles/ctf-aliases)
    echo "$zsh_rc" >> ~/.zshrc
    echo "$zsh_rc" >> ~/.bash_aliases

    echo "\nCTF tmux.conf"
    # tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-tmux.conf)
    tmux_conf=$(cat ./dotfiles/ctf-tmux.conf)
    echo "$tmux_conf" > ~/.tmux.conf
fi