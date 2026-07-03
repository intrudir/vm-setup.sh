#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
DEFAULT_SOURCE_URL="https://raw.githubusercontent.com/intrudir/vm-setup.sh/main"
SOURCE_URL="$DEFAULT_SOURCE_URL"
PROFILE="ctf"
ONLY=""
YES=false
DRY_RUN=false
FORCE_GO=false
BACKUP_DIR="${HOME}/.vm-setup-backups/$(date +%Y%m%d-%H%M%S)"
TOOLS_DIR="/opt/tools"
LOCAL_ROOT=""

BASE_PACKAGES_LINUX=(dnsutils net-tools curl git tmux zsh wget fontconfig python3-pip python3-venv gcc vim ca-certificates)
BASE_PACKAGES_MAC=(curl git tmux zsh wget fontconfig python3 vim go)
CTF_GO_TOOLS=(
  "anew:github.com/tomnomnom/anew@latest"
  "ffuf:github.com/ffuf/ffuf@latest"
  "gron:github.com/tomnomnom/gron@latest"
  "httpx:github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "katana:github.com/projectdiscovery/katana/cmd/katana@latest"
)
FULL_GO_TOOLS=(
  "httprobe:github.com/tomnomnom/httprobe@latest"
  "interactsh-client:github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
  "interactsh-server:github.com/projectdiscovery/interactsh/cmd/interactsh-server@latest"
  "amass:github.com/OWASP/Amass/v3/...@master"
  "nuclei:github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
  "dnsx:github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
)

usage() {
  cat <<EOF
Usage:
  ${SCRIPT_NAME} [options]

Examples:
  curl -fsSL ${DEFAULT_SOURCE_URL}/vm-setup.sh | bash -s -- --profile ctf
  ./${SCRIPT_NAME} --profile full --yes
  ./${SCRIPT_NAME} --only configs,go --dry-run

Options:
  --profile <configs|ctf|full|mac>  Install profile. Default: ctf
  --only <list>                     Comma-separated components: configs,base,go,tools
  --yes                             Do not prompt for confirmation
  --dry-run                         Print actions without changing files
  --backup-dir <path>               Backup directory for replaced configs
  --source-url <url>                Raw source URL for remote dotfiles
  --tools-dir <path>                Directory for source-based tools. Default: /opt/tools
  --force-go                        Reinstall Go even when a Go binary exists
  -h, --help                        Show this help
EOF
}

log() {
  printf '[*] %s\n' "$*"
}

die() {
  printf '[!] %s\n' "$*" >&2
  exit 1
}

run() {
  if "$DRY_RUN"; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

sudo_run() {
  if [[ "${EUID}" -eq 0 ]]; then
    run "$@"
  else
    run sudo "$@"
  fi
}

confirm() {
  local prompt="$1"
  local answer=""

  if "$YES"; then
    return 0
  fi
  if "$DRY_RUN"; then
    return 0
  fi

  if [[ ! -r /dev/tty ]]; then
    die "Confirmation required but no TTY is available. Re-run with --yes to proceed non-interactively."
  fi

  printf '%s [y/N] ' "$prompt" > /dev/tty
  read -r answer < /dev/tty
  [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        [[ $# -ge 2 ]] || die "--profile requires a value"
        PROFILE="$2"
        shift 2
        ;;
      --profile=*)
        PROFILE="${1#*=}"
        shift
        ;;
      --only)
        [[ $# -ge 2 ]] || die "--only requires a value"
        ONLY="$2"
        shift 2
        ;;
      --only=*)
        ONLY="${1#*=}"
        shift
        ;;
      --yes|-y)
        YES=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --backup-dir)
        [[ $# -ge 2 ]] || die "--backup-dir requires a value"
        BACKUP_DIR="$2"
        shift 2
        ;;
      --backup-dir=*)
        BACKUP_DIR="${1#*=}"
        shift
        ;;
      --source-url)
        [[ $# -ge 2 ]] || die "--source-url requires a value"
        SOURCE_URL="${2%/}"
        shift 2
        ;;
      --source-url=*)
        SOURCE_URL="${1#*=}"
        SOURCE_URL="${SOURCE_URL%/}"
        shift
        ;;
      --tools-dir)
        [[ $# -ge 2 ]] || die "--tools-dir requires a value"
        TOOLS_DIR="$2"
        shift 2
        ;;
      --tools-dir=*)
        TOOLS_DIR="${1#*=}"
        shift
        ;;
      --force-go)
        FORCE_GO=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done
}

detect_local_root() {
  local candidate
  candidate="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
  if [[ -n "$candidate" && -d "$candidate/dotfiles" ]]; then
    LOCAL_ROOT="$candidate"
  fi
}

detect_platform() {
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"

  case "$OS" in
    linux)
      if command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
      else
        PACKAGE_MANAGER="none"
      fi
      ;;
    darwin)
      if command -v brew >/dev/null 2>&1; then
        PACKAGE_MANAGER="brew"
      else
        PACKAGE_MANAGER="none"
      fi
      ;;
    *)
      die "Unsupported operating system: $OS"
      ;;
  esac

  case "$ARCH" in
    x86_64|amd64) GO_ARCH="amd64" ;;
    arm64|aarch64|armv8*) GO_ARCH="arm64" ;;
    armv6*|armv7*) GO_ARCH="armv6l" ;;
    i386|i686) GO_ARCH="386" ;;
    *) die "Unsupported architecture: $ARCH" ;;
  esac
}

components_for_profile() {
  case "$PROFILE" in
    configs) COMPONENTS=(configs) ;;
    ctf) COMPONENTS=(configs base go tools) ;;
    full) COMPONENTS=(configs base go tools) ;;
    mac)
      [[ "$OS" == "darwin" ]] || die "--profile mac can only be used on macOS"
      COMPONENTS=(configs base go tools)
      ;;
    *) die "Unknown profile: $PROFILE" ;;
  esac

  if [[ -n "$ONLY" ]]; then
    IFS=',' read -r -a COMPONENTS <<< "$ONLY"
  fi

  local component
  for component in "${COMPONENTS[@]}"; do
    case "$component" in
      configs|base|go|tools) ;;
      *) die "Unknown component in --only: $component" ;;
    esac
  done
}

has_component() {
  local wanted="$1"
  local component
  for component in "${COMPONENTS[@]}"; do
    if [[ "$component" == "$wanted" ]]; then
      return 0
    fi
  done
  return 1
}

install_base_packages() {
  log "Installing base packages for $OS"
  [[ "$PACKAGE_MANAGER" != "none" ]] || die "No supported package manager found. Linux requires apt-get; macOS requires Homebrew."
  if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
    sudo_run apt-get update
    sudo_run apt-get install -y "${BASE_PACKAGES_LINUX[@]}"
    sudo_run apt-get install -y zsh-autosuggestions zsh-syntax-highlighting || \
      log "zsh autosuggestions/highlighting packages unavailable; continuing"
  else
    run brew update
    run brew install "${BASE_PACKAGES_MAC[@]}"
  fi
}

fetch_dotfile() {
  local name="$1"
  local target="$2"
  local url="${SOURCE_URL}/dotfiles/${name}"

  if [[ -n "$LOCAL_ROOT" && -f "$LOCAL_ROOT/dotfiles/$name" ]]; then
    run cp -f "$LOCAL_ROOT/dotfiles/$name" "$target"
  else
    run curl -fsSL "$url" -o "$target"
  fi
}

backup_file() {
  local file="$1"
  local backup="$BACKUP_DIR/$(basename "$file")"
  if [[ ! -e "$file" ]]; then
    return 0
  fi
  if [[ -e "$backup" ]]; then
    return 0
  fi

  run mkdir -p "$BACKUP_DIR"
  run cp -p "$file" "$backup"
}

install_dotfile() {
  local source_name="$1"
  local target="$2"

  if [[ -e "$target" ]]; then
    confirm "Replace $target? A backup will be written to $BACKUP_DIR." || {
      log "Skipping $target"
      return 0
    }
    backup_file "$target"
  fi

  log "Installing $target"
  fetch_dotfile "$source_name" "$target"
}

managed_block() {
  cat <<'EOF'
# >>> vm-setup managed >>>
[ -f "$HOME/.custom_shell_funcs" ] && . "$HOME/.custom_shell_funcs"
[ -f "$HOME/.custom_shell_aliases" ] && . "$HOME/.custom_shell_aliases"
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
case ":$PATH:" in
  *":$GOROOT/bin:"*) ;;
  *) PATH="$PATH:$GOROOT/bin" ;;
esac
case ":$PATH:" in
  *":$GOPATH/bin:"*) ;;
  *) PATH="$PATH:$GOPATH/bin" ;;
esac
export PATH
# <<< vm-setup managed <<<
EOF
}

zsh_key_block() {
  cat <<'EOF'
# >>> vm-setup zsh keys >>>
if [ -n "$ZSH_VERSION" ]; then
  bindkey '^[b' backward-word
  bindkey '^[f' forward-word
  bindkey '\e[1~' beginning-of-line
  bindkey '\e[4~' end-of-line
  [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# <<< vm-setup zsh keys <<<
EOF
}

replace_managed_block() {
  local file="$1"
  local start="$2"
  local end="$3"
  local temp

  temp="$(mktemp)"
  if [[ -f "$file" ]]; then
    awk -v start="$start" -v end="$end" '
      $0 == start { skip=1; next }
      $0 == end { skip=0; next }
      !skip { print }
    ' "$file" > "$temp"
  fi

  run cp "$temp" "$file"
  rm -f "$temp"
}

append_block() {
  local file="$1"
  local block_func="$2"
  local start="$3"
  local end="$4"
  local temp

  if [[ -e "$file" ]]; then
    backup_file "$file"
  fi
  run touch "$file"
  replace_managed_block "$file" "$start" "$end"

  temp="$(mktemp)"
  "$block_func" > "$temp"
  if "$DRY_RUN"; then
    printf '[dry-run] append managed block to %s\n' "$file"
    rm -f "$temp"
  else
    printf '\n' >> "$file"
    cat "$temp" >> "$file"
    rm -f "$temp"
  fi
}

configure_shells() {
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    log "Configuring $rc"
    append_block "$rc" managed_block "# >>> vm-setup managed >>>" "# <<< vm-setup managed <<<"
  done

  append_block "$HOME/.zshrc" zsh_key_block "# >>> vm-setup zsh keys >>>" "# <<< vm-setup zsh keys <<<"
}

install_configs() {
  log "Installing shell, vim, and tmux configs"
  install_dotfile "vimrc" "$HOME/.vimrc"
  install_dotfile "tmux.conf" "$HOME/.tmux.conf"
  install_dotfile "custom_shell_funcs" "$HOME/.custom_shell_funcs"
  install_dotfile "custom_shell_aliases" "$HOME/.custom_shell_aliases"
  configure_shells
}

latest_go_version() {
  curl -fsSL 'https://go.dev/VERSION?m=text' | awk '/^go[0-9]+\.[0-9]+(\.[0-9]+)?$/ { print; exit }'
}

installed_go_version() {
  if command -v go >/dev/null 2>&1; then
    go version | awk '{ print $3 }'
  fi
}

install_go_linux() {
  local version="$1"
  local tarball="${version}.${OS}-${GO_ARCH}.tar.gz"
  local url="https://go.dev/dl/${tarball}"
  local dest="/tmp/${tarball}"

  log "Downloading $url"
  run curl -fL --progress-bar "$url" -o "$dest"

  if [[ -d /usr/local/go ]]; then
    log "Removing existing /usr/local/go"
    sudo_run rm -rf /usr/local/go
  fi

  sudo_run tar -C /usr/local -xzf "$dest"
  run rm -f "$dest"
}

install_go() {
  local version
  local current

  if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    if command -v go >/dev/null 2>&1 && ! "$FORCE_GO"; then
      log "Go already installed: $(go version)"
      return 0
    fi
    run brew install go
    return 0
  fi

  [[ "$OS" == "linux" ]] || die "Go installation on macOS requires Homebrew"

  version="$(latest_go_version)"
  [[ -n "$version" ]] || die "Could not determine latest Go version"
  current="$(installed_go_version || true)"

  if [[ "$current" == "$version" && "$FORCE_GO" == false ]]; then
    log "Go $version already installed"
    return 0
  fi

  install_go_linux "$version"
}

ensure_go_path() {
  export GOROOT="/usr/local/go"
  export GOPATH="${HOME}/go"
  export PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"
}

install_go_tool() {
  local item="$1"
  local name="${item%%:*}"
  local package="${item#*:}"

  log "Installing $name"
  run go install -v "$package"
}

install_dnsgen() {
  log "Installing dnsgen"
  sudo_run mkdir -p "$TOOLS_DIR"
  sudo_run chown "$(id -un)" "$TOOLS_DIR"

  if [[ -d "$TOOLS_DIR/dnsgen/.git" ]]; then
    run git -C "$TOOLS_DIR/dnsgen" pull --ff-only
  else
    run git clone https://github.com/ProjectAnte/dnsgen "$TOOLS_DIR/dnsgen"
  fi

  run python3 -m venv "$TOOLS_DIR/dnsgen/.venv"
  run "$TOOLS_DIR/dnsgen/.venv/bin/python" -m pip install --upgrade pip
  run "$TOOLS_DIR/dnsgen/.venv/bin/python" -m pip install dnsgen
}

install_tools() {
  local item

  ensure_go_path
  if ! "$DRY_RUN"; then
    command -v go >/dev/null 2>&1 || die "Go is required before installing Go-based tools"
  fi

  for item in "${CTF_GO_TOOLS[@]}"; do
    install_go_tool "$item"
  done

  if [[ "$PROFILE" == "full" ]]; then
    for item in "${FULL_GO_TOOLS[@]}"; do
      install_go_tool "$item"
    done

    if command -v nuclei >/dev/null 2>&1; then
      run nuclei -update-templates
    else
      log "nuclei is not on PATH yet; skipping template update until next shell"
    fi

    install_dnsgen
  fi
}

print_summary() {
  log "Profile: $PROFILE"
  log "Components: ${COMPONENTS[*]}"
  log "OS: $OS ($PACKAGE_MANAGER), arch: $ARCH"
  log "Source URL: $SOURCE_URL"
  log "Backup dir: $BACKUP_DIR"
  if "$DRY_RUN"; then
    log "Dry-run mode enabled"
  fi
}

main() {
  parse_args "$@"
  detect_local_root
  detect_platform
  components_for_profile
  print_summary

  if ! "$YES" && ! "$DRY_RUN"; then
    confirm "Proceed with vm setup?" || die "Aborted"
  fi

  if has_component base; then
    install_base_packages
  fi
  if has_component configs; then
    install_configs
  fi
  if has_component go; then
    install_go
  fi
  if has_component tools; then
    install_tools
  fi

  log "Done. Open a new shell or source ~/.bashrc / ~/.zshrc to load changes."
}

main "$@"
