#!/bin/bash

echo "Running environment setup..."

GIT_BASE="https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/dotfiles"

# -----------------------------
# UTILS
# -----------------------------
function check_if_success {
    if [ $? -ne 0 ]; then
        echo "ERROR: Something failed. Stopping."
        exit 1
    fi
}

# -----------------------------
# SELECT LOCAL OR REMOTE DOTFILES
# -----------------------------
if [ -d "./dotfiles" ]; then
    echo "[*] Found ./dotfiles — using local files"
    USE_LOCAL=true
else
    echo "[*] No ./dotfiles folder — downloading from GitHub"
    USE_LOCAL=false
fi

function get_dotfile {
    local filename="$1"
    local target="$2"   # e.g. ~/.vimrc

    if $USE_LOCAL && [ -f "./dotfiles/$filename" ]; then
        echo "Using local ./dotfiles/$filename → $target"
        cp -f "./dotfiles/$filename" "$target"
        check_if_success
        return
    fi

    echo "Downloading $filename → $target"
    curl -fsSL "$GIT_BASE/$filename" -o "$target"
    check_if_success
}

get_dotfile "vimrc"                "$HOME/.vimrc"
get_dotfile "tmux.conf"            "$HOME/.tmux.conf"
get_dotfile "custom_shell_funcs"   "$HOME/.custom_shell_funcs"
get_dotfile "custom_shell_aliases" "$HOME/.custom_shell_aliases"

# -----------------------------
# OPTIONAL ZSH DEFAULT SHELL SWITCH
# -----------------------------
function attempt_switch_to_zsh {
    if ! command -v zsh >/dev/null; then
        echo "Zsh not installed — skipping."
        return
    fi

    echo "Zsh detected. Automatically start zsh for all future shells? [y/N]"
    read -r resp < /dev/tty

    if [[ "$resp" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Setting future shells to auto-switch to zsh..."

        # Only append if not already present
        if ! grep -q 'exec zsh -l' "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Auto-switch to zsh for future shells" >> "$HOME/.bashrc"
            echo '[ -z "$ZSH_VERSION" ] && exec zsh -l' >> "$HOME/.bashrc"
        fi

        # Immediately switch current session to zsh
        echo "Switching current shell to zsh..."
        exec zsh -l
    else
        echo "Not enabling zsh auto-switch."
    fi
}



attempt_switch_to_zsh

# -----------------------------------------
# HANDLE OH-MY-ZSH VS REGULAR SHELL SETUP
# -----------------------------------------

if [ -n "$ZSH_CUSTOM" ] && [ -d "$ZSH_CUSTOM" ]; then
    echo "[*] Oh-My-Zsh detected — installing into \$ZSH_CUSTOM"

    # Copy into Oh-My-Zsh autoload locations
    cp -f "$HOME/.custom_shell_funcs"   "$ZSH_CUSTOM/custom_shell_funcs.zsh"
    cp -f "$HOME/.custom_shell_aliases" "$ZSH_CUSTOM/custom_shell_aliases.zsh"

    # When using Oh-My-Zsh, DO NOT modify ~/.zshrc
    # Oh-My-Zsh will source custom plugins automatically.
    
else
    echo "[*] Oh-My-Zsh NOT found — sourcing files manually"

    function ensure_sourcing {
        local rc="$1"
        local funcs="$HOME/.custom_shell_funcs"
        local aliases="$HOME/.custom_shell_aliases"

        [ -f "$rc" ] || touch "$rc"

        grep -q ".custom_shell_funcs" "$rc" || \
            echo "[ -f $funcs ] && . $funcs" >> "$rc"

        grep -q ".custom_shell_aliases" "$rc" || \
            echo "[ -f $aliases ] && . $aliases" >> "$rc"

        # ZSH-only keybindings (only when NOT using Oh-My-Zsh)
        if [[ "$rc" == "$HOME/.zshrc" ]]; then
            grep -q "backward-word" "$rc" || echo "bindkey '^[b' backward-word" >> "$rc"
            grep -q "forward-word"  "$rc" || echo "bindkey '^[f' forward-word" >> "$rc"
            grep -q "beginning-of-line" "$rc" || echo "bindkey '\e[1~' beginning-of-line" >> "$rc"
            grep -q "end-of-line"       "$rc" || echo "bindkey '\e[4~' end-of-line" >> "$rc"
        fi
    }

    # Source for bash + zsh only if Oh-My-Zsh is not present
    ensure_sourcing "$HOME/.bashrc"
    ensure_sourcing "$HOME/.zshrc"
fi


# -----------------------------
# INSTALL tmux-power THEME
# -----------------------------
# echo "Installing tmux-power theme..."

# sudo mkdir -p /opt/tmux
# check_if_success

# if [ ! -d /opt/tmux/tmux-power ]; then
#     sudo git clone https://github.com/wfxr/tmux-power.git /opt/tmux/tmux-power
# else
#     echo "tmux-power already installed."
# fi

# if ! grep -q "tmux-power.tmux" "$HOME/.tmux.conf"; then
#     echo "run-shell \"/opt/tmux/tmux-power/tmux-power.tmux\"" >> "$HOME/.tmux.conf"
# fi

echo "Setup complete!"
