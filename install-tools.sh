#!/bin/bash

# Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

# Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

# Help function
function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT -t [full, ctf]${NORM}"\\n
  echo "${REV}-t${NORM}  --Choose between 'full' or 'ctf' VM installs."
  echo -e "${REV}-h${NORM}  --Displays this help message and exits."\\n
  echo -e "Example: ${BOLD}$SCRIPT -t ctf"\\n
  exit 1
}

function check_if_success () {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "Something went wrong. Stopping here so you can check the error."
        exit
    fi
}

# Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

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

# make tools directory
sudo mkdir -p /opt/tools
sudo chown $(whoami) -R /opt/tools
check_if_success

# anew
go install github.com/tomnomnom/anew@latest

# ffuf
go install github.com/ffuf/ffuf@latest

# gron - make JSON greppable!
go install github.com/tomnomnom/gron@latest

# httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Katana
go install github.com/projectdiscovery/katana/cmd/katana@latest

# Only install these if type == full
if [[ $type == 'full' ]]; then
    # httprobe
    go install github.com/tomnomnom/httprobe@latest

    # interactsh client
    go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

    # interactsh server
    go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-server@latest

    # amass
    go install -v github.com/OWASP/Amass/v3/...@master

    # nuclei
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

    # nuclei templates
    nuclei -update-templates

    # install dnsx
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

    # Install dnsgen
    cd /opt/tools
    git clone https://github.com/ProjectAnte/dnsgen
    cd dnsgen
    python3 -m venv .venv
    source ./.venv/bin/activate
    python3 -m pip install dnsgen
    check_if_success
    deactivate
fi