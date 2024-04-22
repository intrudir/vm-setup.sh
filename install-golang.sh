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
            *)
                echo "Unsupported architecture: $ARCH"
                exit 1
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
            *)
                echo "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

PLATFORM="$OS-$ARCH"
echo "Determined PLATFORM: $PLATFORM"

INSTALL_DIR="/usr/local"
LATEST_GO_VERSION="$(curl -s 'https://go.dev/VERSION?m=text' | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+')"
if [ $? -ne 0 ]; then
    echo "Failed to fetch the latest Go version."
    exit 1
fi

# Trim the version string to remove any unwanted characters like newlines
LATEST_GO_VERSION=$(echo $LATEST_GO_VERSION | tr -d '[:space:]')

GO_TAR="${LATEST_GO_VERSION}.${PLATFORM}.tar.gz"
LATEST_GO_DOWNLOAD="https://golang.org/dl/$GO_TAR"

echo "cd to installation directory ($INSTALL_DIR)"
cd "$INSTALL_DIR" || { echo "Failed to change directory to $INSTALL_DIR"; exit 1; }

echo "Downloading ${LATEST_GO_DOWNLOAD} to /tmp"
curl -o "/tmp/$GO_TAR" -L --progress-bar "$LATEST_GO_DOWNLOAD" || { echo "Download failed"; exit 1; }

echo "Extracting file to ${INSTALL_DIR}"
sudo tar -xf "/tmp/$GO_TAR" -C "$INSTALL_DIR" || { echo "Failed to extract files"; exit 1; }

echo "Configuring environment variables"
golang_paths='
# golang stuff
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
'

echo "$golang_paths" >> ~/.zshrc
echo "$golang_paths" >> ~/.bashrc
rm "$GO_TAR"

echo "Installation complete. Please restart your shell or source your profile to apply changes."
