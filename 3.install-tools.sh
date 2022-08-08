# Install the latest golang
LATEST_GO_VERSION=$(curl "https://go.dev/VERSION?m=text")
LATEST_GO_DOWNLOAD="https://golang.org/dl/$LATEST_GO_VERSION.linux-amd64.tar.gz"

printf "cd to home ($USER) directory \n"
cd "/home/$USER"

printf "Downloading ${LATEST_GO_DOWNLOAD}\n\n";
curl -OJ -L --progress-bar "$LATEST_GO_DOWNLOAD"

printf "Extracting file...\n"
tar -xf ${LATEST_GO_VERSION}.linux-amd64.tar.gz

golang_path='

# golang stuff
export GOROOT="/home/$USER/go"
export GOPATH="/home/$USER/go/packages"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

'
echo "$golang_path" >> ~/.zshrc

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