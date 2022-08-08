#!/bin/bash

function check_if_success () {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Something went wrong. Stopping here so you can check the error."
        exit
    fi
}

# Make sure sudo is installed
sudo -l
check_if_success

# install stuff
sudo apt install dnsutils net-tools curl git tmux zsh wget
check_if_success

# change default shell for user
sudo chsh -s $(which zsh) $(whoami)
check_if_success

# Install OhMyZsh!
echo exit | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install necessary fonts for powerlevel10k
wget -N https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -N https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -N https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -N https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

sudo mv *.ttf /usr/share/fonts

sudo fc-cache -f
check_if_success

read -p "Press any key to resume after installing fonts ..."
echo "The pk10 fonts have been installed. You may need to manually set them in your terminal if it didn't automatically do it."

# install P10K
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo 'source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo
echo
echo "Your default shell has been changed. You need to log out completely and back in for it to take effect!"
echo "When logging back in, open your terminal and configure P10K how you like it."
exit