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
  OS="$(uname --kernel-name)" || return 1
  ARCH="$(uname --machine)" || return 1

  case "$OS" in
  Linux)
    source ./linux.sh
    ;;
  Darwin)
    source ./darwin.sh
    ;;
  *)
    error "Platform unsupported: $OS"
    return 1
    ;;
  esac
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
  sudo_session_pid=$!
  trap 'kill "$sudo_session_pid" 2>/dev/null' EXIT HUP INT QUIT TERM
}

install_tools() {
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
      warn "$tool" "Skipping - tool was excluded"
      continue
    fi

    is_installed_fn="is_installed_$tool"
    install_fn="install_$tool"
    check_fn "$tool" "$is_installed_fn" "$install_fn" || return 1

    if ! "$is_installed_fn"; then
      $install_fn && info "$tool" "Installed successfully"
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
