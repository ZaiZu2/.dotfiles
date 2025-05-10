source utils.sh

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -e | --exclude)
      EXCLUDED=$2
      shift 2
      ;;
    -o | --only)
      ONLY=$2
      shift 2
      ;;
    *)
      error "Unknown option: $1"
      did_error=true
      shift
      ;;
    esac
  done
  if [[ "${did_error:-}" == true ]]; then
    return 1
  fi
}

load_platform() {
  OS="$(uname --kernel-name | tr '[:upper:]' '[:lower:]')" || return 1
  if ! [[ $OS =~ ^(linux)|(darwin)$ ]]; then
    error "Platform unsupported: $OS"
    exit 1
  fi

  ARCH="$(uname --machine | tr '[:upper:]' '[:lower:]')" || return 1
  if ! [[ $ARCH =~ ^(x86_64)|(arm64)$ ]]; then
    error "Architecture unsupported: $ARCH"
    exit 1
  fi

  info "Platform recognized as $OS-$ARCH"
  source "./${OS}.sh"
}

open_sudo_session() {
  # Invalidate any cached credentials if they are incorrect
  if sudo --non-interactive true 2>/dev/null; then
    sudo --remove-timestamp
    info "Provide admin credentials:"
  fi

  if ! sudo --validate; then
    error "This script requires admin rights"
    exit 1
  fi

  (while true; do
    sudo -n true
    sleep 60
  done) &
  SUDO_SESSION_PID=$!
  trap 'kill "$SUDO_SESSION_PID" 2>/dev/null' EXIT HUP INT QUIT TERM
}

install_tools() {
  info "Installing tools..."
  for file in "./tools/"*; do
    source "$file"

    basename="$(basename "$file")"
    tool="${basename%%.sh}"

    # Iterate over select tools if --only was set
    if [[ -n "${ONLY:-}" && ",$ONLY," != *",$tool,"* ]]; then
      continue
    fi
    # Skip excluded tools
    if [[ ${EXCLUDED+x} && ",$EXCLUDED," == *",$tool,"* ]]; then
      continue
    fi

    is_installed_fn="is_installed_$tool"
    install_fn="install_$tool"
    check_fn "$tool" "$is_installed_fn" "$install_fn" || return 1

    if ! "$is_installed_fn"; then
      if $install_fn; then
        info "$tool" "Installed successfully"
      else
        error "$tool" "Error occured during installation"
      fi
    else
      warn "$tool" "Skipping - tool is already installed"
    fi
  done
}

main() {
  parse_args "$@" || return 1
  load_platform || return 1
  open_sudo_session
  init_pkg_mgr || return 1
  install_tools
}

main "$@"
