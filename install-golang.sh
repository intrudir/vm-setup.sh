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

LATEST_GO_VERSION="$(curl 'https://go.dev/VERSION?m=text')"
GO_TAR="$LATEST_GO_VERSION.$OS-$ARCH.tar.gz"
LATEST_GO_DOWNLOAD="https://golang.org/dl/$GO_TAR"

printf "cd to home ($USER) directory \n"
cd "/home/$USER"

printf "Downloading ${LATEST_GO_DOWNLOAD}\n\n";
curl -OJ -L --progress-bar "$LATEST_GO_DOWNLOAD"

printf "Extracting file...\n"
tar -xf "$GO_TAR"

golang_paths="
# golang stuff
export GOROOT=\"\$HOME/go\"
export GOPATH=\"\$HOME/go/packages\"
export PATH=\"\$PATH:\$GOROOT/bin:\$GOPATH/bin\"
"
echo "$golang_paths" >> ~/.zshrc
echo "$golang_paths" >> ~/.bashrc