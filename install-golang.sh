#!/bin/bash

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
        ;;
esac

PLATFORM="$OS-$ARCH"
LATEST_GO_VERSION="$(curl 'https://go.dev/VERSION?m=text')"
INSTALL_DIR="/usr/local"
if [ $? -ne 0 ]; then
    echo "Failed to fetch the latest Go version."
    exit 1
fi

GO_TAR="${LATEST_GO_VERSION}.${PLATFORM}.tar.gz"
LATEST_GO_DOWNLOAD="https://golang.org/dl/$GO_TAR"

echo "cd to installation directory ($INSTALL_DIR)"
cd "$INSTALL_DIR" || { echo "Failed to change directory to $INSTALL_DIR"; exit 1; }

echo "Downloading ${LATEST_GO_DOWNLOAD}"
curl -OJL --progress-bar "$LATEST_GO_DOWNLOAD" || { echo "Download failed"; exit 1; }

echo "Extracting file..."
tar -xf "$GO_TAR" || { echo "Failed to extract files"; exit 1; }

echo "Configuring environment variables"
golang_paths="
# golang stuff
export GOROOT='${INSTALL_DIR}/go'
export GOPATH='\$HOME/go'
export PATH='\$PATH:\$GOROOT/bin:\$GOPATH/bin'
"
echo "$golang_paths" >> ~/.zshrc
echo "$golang_paths" >> ~/.bashrc
rm "$GO_TAR"

echo "Installation complete. Please restart your shell or source your profile to apply changes."
