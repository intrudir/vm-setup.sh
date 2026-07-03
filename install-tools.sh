#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROFILE="ctf"
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t)
      [[ $# -ge 2 ]] || {
        echo "-t requires ctf or full" >&2
        exit 1
      }
      PROFILE="$2"
      shift 2
      ;;
    -t=*)
      PROFILE="${1#*=}"
      shift
      ;;
    --profile|--profile=*)
      ARGS+=("$1")
      if [[ "$1" == "--profile" ]]; then
        [[ $# -ge 2 ]] || {
          echo "--profile requires a value" >&2
          exit 1
        }
        ARGS+=("$2")
        shift 2
      else
        shift
      fi
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

exec "$SCRIPT_DIR/vm-setup.sh" --profile "$PROFILE" --only tools "${ARGS[@]}"
