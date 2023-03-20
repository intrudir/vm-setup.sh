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