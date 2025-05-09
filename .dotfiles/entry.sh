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
    -f | --force)
      FORCE='true'
      shift
      ;;
    -s | --skip-pkg-mgr)
      SKIP_PKG_MGR='true'
      shift
      ;;
    *)
      error "Unknown option: $1"
      local did_error=true
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

  case "$OS" in
  linux | darwin) ;;
  *)
    error "Platform unsupported: $OS"
    exit 1
    ;;
  esac

  ARCH="$(uname --machine | tr '[:upper:]' '[:lower:]')" || return 1
  case "$ARCH" in
  x86_64 | arm64) ;;
  *)
    error "Architecture unsupported: $ARCH"
    exit 1
    ;;
  esac

  info "Platform recognized as $OS-$ARCH"
  source "$SCRIPT_DIR/$OS.sh"
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
  for file in "$SCRIPT_DIR/tools/"*; do
    source "$file"

    local filename="$(basename "$file")"
    local tool="${filename%%.sh}"

    # Iterate over select tools if --only was set
    if [[ -n "${ONLY:-}" && ",$ONLY," != *",$tool,"* ]]; then
      continue
    fi
    # Skip excluded tools
    if [[ ${EXCLUDED+x} && ",$EXCLUDED," == *",$tool,"* ]]; then
      continue
    fi

    local is_installed_fn="is_installed_$tool"
    local install_fn="install_$tool"
    check_fn "$tool" "$is_installed_fn" "$install_fn" || return 1

    if ! "$is_installed_fn" || [ "$FORCE" = 'true' ]; then
      info "$tool" "Installing..."
      if log_tool_block "$install_fn"; then
        info "$tool" "Installed successfully"
      else
        error "$tool" "Error occured during installation"
      fi
    else
      warn "$tool" "Skipping - tool is already installed"
    fi
  done
}

symlink_dotfiles() {
  ls "$SCRIPT_DIR/files/dotfiles/"
  for dotfile in "$SCRIPT_DIR/files/dotfiles/."*; do
    ln -sf "$dotfile" "$HOME/$(basename "$dotfile")"
  done
  info "Symlinked dotfiles"
}

main() {
  parse_args "$@" || return $?
  SCRIPT_DIR="$(get_script_dir)"
  load_platform || return $?

  symlink_dotfiles
  open_sudo_session
  install_font
  [ "$SKIP_PKG_MGR" = 'true' ] || init_pkg_mgr || return $?
  install_tools
}

main "$@"
