#!/bin/bash

# Set Script Name variable
SCRIPT=$(basename "${BASH_SOURCE[0]}")

# Set fonts for Help.
NORM=$(tput sgr0)
BOLD=$(tput bold)
REV=$(tput smso)

switch_to_zsh="no"

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
    local custom_aliases_file="$1"
    local custom_funcs_file="$2"
    local bash_rc="$HOME/.bashrc"
    local zsh_rc="$HOME/.zshrc"
    local custom_funcs_path="$HOME/.custom_shell_funcs"
    local custom_aliases_path="$HOME/.custom_shell_aliases"

    # Copy functions
    if [ -f "$custom_funcs_file" ]; then
        echo "Deploying custom shell functions"
        cp -f "$custom_funcs_file" "$custom_funcs_path"
    else
        echo "Custom functions file missing: $custom_funcs_file"
    fi

    # Copy aliases
    if [ -f "$custom_aliases_file" ]; then
        echo "Deploying custom shell aliases"
        cp -f "$custom_aliases_file" "$custom_aliases_path"
    else
        echo "Custom aliases file missing: $custom_aliases_file"
    fi

    # Source them in .bashrc and .zshrc
    for rc_file in "$bash_rc" "$zsh_rc"; do
        if ! grep -q ".custom_shell_funcs" "$rc_file" 2>/dev/null; then
            echo -e "\n# Source custom shell functions\n[ -f $custom_funcs_path ] && . $custom_funcs_path" >> "$rc_file"
        fi

        if ! grep -q ".custom_shell_aliases" "$rc_file" 2>/dev/null; then
            echo -e "\n# Source custom shell aliases\n[ -f $custom_aliases_path ] && . $custom_aliases_path" >> "$rc_file"
        fi

        # Add keybindings for zsh
        if [ "$rc_file" == "$zsh_rc" ]; then
            grep -q "backward-word" "$zsh_rc" || echo "bindkey '^[b' backward-word" >> "$zsh_rc"
            grep -q "forward-word" "$zsh_rc" || echo "bindkey '^[f' forward-word" >> "$zsh_rc"
        fi
    done
}

function attempt_switch_to_zsh {
    if command -v zsh >/dev/null && [ "$SHELL" != "$(command -v zsh)" ]; then
        local profile_file="$HOME/.bash_profile"
        [ ! -f "$profile_file" ] && profile_file="$HOME/.profile"

        echo "Zsh is available. Switch default shell to Zsh? [y/N]"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            if ! grep -q 'exec "$SHELL" -l' "$profile_file"; then
                echo "export SHELL=$(command -v zsh)" >> "$profile_file"
                echo '[ -z "$ZSH_VERSION" ] && exec "$SHELL" -l' >> "$profile_file"
                echo "Shell switch configured. Log out/in to activate."
            else
                echo "Shell switch already configured."
            fi
        else
            echo "Skipping zsh switch."
        fi
    else
        echo "Zsh not available or already default."
    fi
}

echo "Running environment setup"

# Load configs
vim_rc=$(cat ./dotfiles/vimrc)
tmux_conf=$(cat ./dotfiles/tmux.conf)
custom_funcs_file="./dotfiles/custom_shell_funcs"
custom_aliases_file="./dotfiles/custom_shell_aliases"

# Switch to zsh if wanted
attempt_switch_to_zsh

# Apply shell configs
apply_shell_configurations "$custom_aliases_file" "$custom_funcs_file"

# Install vimrc
echo "Installing vim config"
echo "$vim_rc" > ~/.vimrc

# Install tmux conf
echo "Installing tmux config"
echo "$tmux_conf" > ~/.tmux.conf

# Install vim-plug
echo "Installing vim plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
check_if_success

# Install tmux themes
echo "Installing tmux themes"
sudo mkdir -p /opt/tmux
check_if_success

cd /opt/tmux || { echo "Failed to cd to /opt/tmux"; exit 1; }

if [ ! -d tmux-power ]; then
    sudo git clone https://github.com/wfxr/tmux-power.git
    check_if_success
else
    echo "tmux-power already exists; skipping clone."
fi

if ! grep -q "tmux-power.tmux" ~/.tmux.conf; then
    echo -e "\n# Tmux themes\nrun-shell \"/opt/tmux/tmux-power/tmux-power.tmux\"" >> ~/.tmux.conf
fi

echo "Setup complete!"
