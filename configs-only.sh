#!/bin/bash
function check_if_success () {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Something went wrong. Stopping here so you can check the error."
        exit
    fi
}
# Install VIM plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
check_if_success

# CTF vim config
vim_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/vimrc)
echo "$vim_rc" > ~/.vimrc

# CTF shell aliases
zsh_rc=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-aliases)
echo "$zsh_rc" >> ~/.zshrc

# Install tmux themes
sudo mkdir /opt/tmux && cd /opt/tmux
check_if_success
sudo git clone https://github.com/wfxr/tmux-power.git
cd ~

# CTF tmux.conf
tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-tmux.conf)
echo "$tmux_conf" > ~/.tmux.conf

echo
echo "Now refresh or restart your terminal session!"
