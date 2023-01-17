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
echo "$zsh_rc" >> ~/.bash_aliases

# Install tmux themes
sudo mkdir /opt/tmux && cd /opt/tmux
check_if_success
sudo git clone https://github.com/wfxr/tmux-power.git
cd ~

# CTF tmux.conf
tmux_conf=$(curl https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles/ctf-tmux.conf)
echo "$tmux_conf" > ~/.tmux.conf

# Install the latest golang
wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/install-golang.sh
chmod +x ./install-golang.sh
./install-golang.sh
check_if_success
rm ./install-golang.sh
source ~/.zshrc

# anew
go install github.com/tomnomnom/anew@latest

# nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# nuclei templates
nuclei -update-templates

# gron - make JSON greppable!
go install github.com/tomnomnom/gron@latest

# httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# httprobe
go install github.com/tomnomnom/httprobe@latest

# interactsh client
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

# interactsh server
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-server@latest

# amass
go install -v github.com/OWASP/Amass/v3/...@master

# ffuf
go install github.com/ffuf/ffuf@latest

# Katana
go install github.com/projectdiscovery/katana/cmd/katana@latest

# install dnsx
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# make tools directory
sudo mkdir -p /opt/tools
sudo chown $(whoami) -R /opt/tools
check_if_success

# Install dnsgen
cd /opt/tools
git clone https://github.com/ProjectAnte/dnsgen
check_if_success

cd dnsgen
python3 -m venv .venv
source ./.venv/bin/activate
python3 -m pip install dnsgen
check_if_success
deactivate

# install zsh autosuggestions and syntax highlighting
sudo apt install zsh-autosuggestions zsh-syntax-highlighting
check_if_success
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

