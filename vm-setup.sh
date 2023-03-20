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

echo "vm-setup VM type: $type";

# install stuff
sudo apt install dnsutils net-tools curl git tmux zsh wget fontconfig python3-pip python3-venv gcc
check_if_success

# install zsh autosuggestions and syntax highlighting
sudo apt install zsh-autosuggestions zsh-syntax-highlighting
check_if_success

STRING="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if ! grep -q "$STRING" "~/.zshrc" ; then
    echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
    echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
fi

# Install configs and dependencies for them if any
# wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/install-configs.sh
chmod +x ./install-configs.sh
./install-configs.sh -t "$type"
check_if_success
# rm ./install-configs.sh

# Install the latest golang
# wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/install-golang.sh
chmod +x ./install-golang.sh
./install-golang.sh
check_if_success
# rm ./install-golang.sh

if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
elif [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc
fi

# anew
go install github.com/tomnomnom/anew@latest

# # nuclei
# go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# # nuclei templates
# nuclei -update-templates

# # gron - make JSON greppable!
# go install github.com/tomnomnom/gron@latest

# # httpx
# go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# # httprobe
# go install github.com/tomnomnom/httprobe@latest

# # interactsh client
# go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

# # interactsh server
# go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-server@latest

# # amass
# go install -v github.com/OWASP/Amass/v3/...@master

# # ffuf
# go install github.com/ffuf/ffuf@latest

# # Katana
# go install github.com/projectdiscovery/katana/cmd/katana@latest

# # install dnsx
# go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# # make tools directory
# sudo mkdir -p /opt/tools
# sudo chown $(whoami) -R /opt/tools
# check_if_success

# # Install dnsgen
# cd /opt/tools
# git clone https://github.com/ProjectAnte/dnsgen
# check_if_success

# cd dnsgen
# python3 -m venv .venv
# source ./.venv/bin/activate
# python3 -m pip install dnsgen
# check_if_success
# deactivate



