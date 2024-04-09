#!/bin/bash

# Set Script Name variable
SCRIPT=$(basename "${BASH_SOURCE[0]}")

# Set fonts for Help.
NORM=$(tput sgr0)
BOLD=$(tput bold)
REV=$(tput smso)

# Global variable to track if the user wants to switch to Zsh
switch_to_zsh="no"

# Help function
function HELP {
  echo -e "\nHelp documentation for ${BOLD}${SCRIPT}.${NORM}\n"
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT -t [full, ctf]${NORM}\n"
  echo "${REV}-t${NORM}  --Choose between 'full' or 'ctf' VM installs."
  echo -e "${REV}-h${NORM}  --Displays this help message and exits.\n"
  echo -e "Example: ${BOLD}$SCRIPT -t ctf\n"
  exit 1
}

function check_if_success {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Something went wrong. Stopping here so you can check the error."
        exit 1
    fi
}

# Apply shell aliases and deploy custom shell functions
function apply_shell_configurations {
    local shell_config="$1"
    local custom_funcs_file="$2"
    local bash_rc="$HOME/.bashrc"
    local zsh_rc="$HOME/.zshrc"
    local custom_funcs_path="$HOME/.custom_shell_funcs"

    # Copy the custom shell functions file to the home directory
    if [ -n "$custom_funcs_file" ] && [ -f "$custom_funcs_file" ]; then
        echo "Deploying custom shell functions to $custom_funcs_path"
        cp -f "$custom_funcs_file" "$custom_funcs_path"
    fi

    # Ensure .bashrc and .zshrc source the custom functions file
    for rc_file in "$bash_rc" "$zsh_rc"; do
        if ! grep -q ".custom_shell_funcs" "$rc_file"; then
            echo -e "\n# Source custom shell functions\n[ -f ~/.custom_shell_funcs ] && . ~/.custom_shell_funcs" >> "$rc_file"
        fi
    done

    # Apply configurations to Bash shell
    echo "Applying configurations to $bash_rc"
    echo "$shell_config" >> "$bash_rc"

    # Apply configurations to Zsh shell
    echo "Applying configurations to $zsh_rc"
    echo "$shell_config" >> "$zsh_rc"
}

# Switch to Zsh if available
function attempt_switch_to_zsh {
    if command -v zsh >/dev/null && [ "$SHELL" != "$(command -v zsh)" ]; then
        local profile_file="$HOME/.bash_profile"
        [ ! -f "$profile_file" ] && profile_file="$HOME/.profile"
        
        echo "Zsh is available. Would you like to switch your default shell to Zsh? [y/N]"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            switch_to_zsh="yes"
            if ! grep -q 'exec "$SHELL" -l' "$profile_file"; then
                echo "Switching to Zsh in $profile_file"
                {
                    echo "export SHELL=$(command -v zsh)"
                    echo '[ -z "$ZSH_VERSION" ] && exec "$SHELL" -l'
                } >> "$profile_file"
                echo "Please log out and log back in for the default shell change to take effect."
            else
                echo "Shell switch to Zsh already configured."
            fi
        else
            echo "Skipping shell switch to Zsh."
        fi
    else
        echo "Zsh is not available; continuing with Bash."
    fi
}

# Check the number of arguments. If none are passed, print help and exit.
if [ $# -eq 0 ]; then
  HELP
fi

while getopts 'h:t:' flag; do
    case "${flag}" in
        h) HELP ;;
        
        t) type=${OPTARG} ;;
        
        *) echo "Unexpected option: -${OPTARG}" >&2
           HELP
           exit 1 ;;
    esac
done

if [ -z "$type" ]; then
    echo "The -t flag is required. Needs to be one of the following: ['full', 'ctf']"
    exit 1
fi

if [[ ! $type == 'full' ]] && [[ ! $type == 'ctf' ]]; then
    echo "The -t flag needs to be either 'full' or 'ctf'."
    exit 1
fi

echo "VM type: $type"

# Load configurations
sh_rc=$(cat ./dotfiles/"${type}"-aliases)
vim_rc=$(cat ./dotfiles/"${type}"-vimrc)
tmux_conf=$(cat ./dotfiles/"${type}"-tmux.conf)
custom_funcs_file="./dotfiles/custom_shell_funcs"

# Attempt to switch to Zsh if available and desired by the user
attempt_switch_to_zsh

# Apply shell configurations based on the current shell or user choice
apply_shell_configurations "$sh_rc" "$custom_funcs_file"

if [[ $type == 'full' ]]; then
    echo "Installing VIM plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_if_success

    echo "Installing tmux themes"
    if [ ! -d /opt/tmux ]; then
        sudo mkdir -p /opt/tmux
        check_if_success
    fi
    
    cd /opt/tmux || { echo "Failed to change directory to /opt/tmux"; exit 1; }

    if [ ! -d tmux-power ]; then
        sudo git clone https://github.com/wfxr/tmux-power.git
        check_if_success
    else
        echo "tmux-power already cloned. Skipping."
    fi
fi

# Apply Vim and tmux configurations
echo "Installing $type vim config"
echo "$vim_rc" > ~/.vimrc

echo "Installing $type tmux.conf"
echo "$tmux_conf" > ~/.tmux.conf
