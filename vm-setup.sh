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
if ! grep -q "$STRING" ~/.zshrc ; then
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

if ! [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc 2>/dev/null
elif ! [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc 2>/dev/null
fi

# install tools
# wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/install-tools.sh
chmod +x ./install-tools.sh
./install-tools.sh -t "$type"
check_if_success
# rm ./install-tools.sh