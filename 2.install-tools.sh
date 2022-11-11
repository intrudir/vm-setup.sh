#!/bin/bash

# CTF vim config
vim_rc="
\" turn on syntax highlight
syntax on

\" turn on line numbers
set number

\" make backspace work as intended in edit mode
set backspace=indent,eol,start

\" Indentation
set shiftwidth=4
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

\" Auto indent what you can
set autoindent

\" Display
set ls=2
set noshowmode
set showcmd
set modeline
set ruler
set title
set nu

\" History
set history=50

\" Command shortcuts
\" sort the buffer removing duplicates
nmap <Leader>s :%!sort -u --version-sort<CR>

\" Base64 decode word under cursor
nmap <Leader>b :!echo <C-R><C-W> \| base64 -d<CR>

\" Pretty print XML
nmap <Leader>x :!xmllint --format -
"
echo "$vim_rc" > ~/.vimrc

# CTF shell aliases
zsh_rc="
### my aliases

# required to sudo an aliased command
alias sudo='sudo '

# tmux
alias tml='tmux ls'
alias tma='tmux a -t'
alias tmn='tmux new -s'

# binaries
alias vi='vim'
alias ngrok='/opt/ngrok'

# web
alias secretfinder='python3 /opt/SecretFinder/SecretFinder.py'
alias linkfinder='python3 /opt/LinkFinder/linkfinder.py'

# my_tools
alias bypassfuzzer='python3 ~/my_tools/bypassfuzzer/bypassfuzzer.py'

# Proxy stuff
alias burl='curl -x 127.0.0.1:8080 -k'
alias murl=\"curl -x 127.0.0.1:8080 -k -H $'X-Pwnfox-Color: magenta'\"
alias proxypy='export REQUESTS_CA_BUNDLE=\"path/to/burpcert.pem\"; export HTTP_PROXY=\"http://127.0.0.1:8080\"; export HTTPS_PROXY=\"http://127.0.0.1:8080\"'
alias proxypy_unset='unset REQUESTS_CA_BUNDLE; unset HTTP_PROXY; unset HTTPS_PROXY'

# shortcuts
alias POST='curl -d @-'
alias apachelogs=\"tail -f -n 10 /var/log/apache2/access.log\"
alias udc='python3 -c \"import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))\"'
alias uec='python3 -c \"import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))\"'

# other
export EDITOR=vim
"

echo "$zsh_rc" >> ~/.zshrc

# CTF tmux.conf
tmux_conf="
### enable mouse:
set -g mouse on

### Scrollback buffer
set -g history-limit 65000

### get 256 colors to work, including in vim/nvim
set-option -g default-terminal \"screen-256color\"
set -ga terminal-overrides \",xterm-256color:RGB\"

### fix tmux escape time (for vim/nvim)
set-option -sg escape-time 10

### New windows open in current path
bind c new-window -c \"#{pane_current_path}\"

### New panes open in current path
bind '\"' split-window -c \"#{pane_current_path}\"
bind % split-window -h -c \"#{pane_current_path}\"
"
echo "$tmux_conf" > ~/.tmux.conf
echo
echo "Now refresh or restart your terminal session!"

source ~/.zshrc

# Get user's OS and arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case $OS in
    "linux")
        case $ARCH in
        "x86_64")
            ARCH=amd64
            ;;
        "aarch64")
            ARCH=arm64
            ;;
        "armv6" | "armv7l")
            ARCH=armv6l
            ;;
        "armv8")
            ARCH=arm64
            ;;
        .*386.*)
            ARCH=386
            ;;
        esac
        PLATFORM="linux-$ARCH"
    ;;
    "darwin")
          case $ARCH in
          "x86_64")
              ARCH=amd64
              ;;
          "arm64")
              ARCH=arm64
              ;;
          esac
        PLATFORM="darwin-$ARCH"
    ;;
esac

# Install the latest golang
LATEST_GO_VERSION="$(curl "https://go.dev/VERSION?m=text")"
GO_TAR="$LATEST_GO_VERSION.$OS-$ARCH.tar.gz"
LATEST_GO_DOWNLOAD="https://golang.org/dl/$GO_TAR"

printf "cd to home ($USER) directory \n"
cd "/home/$USER"

printf "Downloading ${LATEST_GO_DOWNLOAD}\n\n";
curl -OJ -L --progress-bar "$LATEST_GO_DOWNLOAD"

printf "Extracting file...\n"
tar -xf "$GO_TAR"

GOLANG_PATH='

# golang stuff
export GOROOT="$HOME/go"
export GOPATH="$HOME/go/packages"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

'

echo "$GOLANG_PATH" >> ~/.zshrc

source ~/.zshrc

# anew
go install github.com/tomnomnom/anew@latest

# nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# nuclei templates
nuclei -update-templates

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

# Install dnsgen
cd /opt/tools
git clone https://github.com/ProjectAnte/dnsgen
cd dnsgen
python3 -m venv .venv
source ./.venv/bin/activate
python3 -m pip install dnsgen
deactivate



