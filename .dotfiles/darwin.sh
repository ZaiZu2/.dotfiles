_is_installed_brew() { command -v brew >/dev/null 2>&1; }

_update_brew() {
  brew update || return 1
}

_install_brew() {
  curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" &&
    NONINTERACTIVE=1 bash -s

  brew install cmake curl pkg-config libtool unzip ripgrep \
    build-essential libreadline-dev gnu-tar coreutils
}

init_pkg_mgr() {
  if ! _is_installed_brew; then
    _install_brew || return 1
  fi

  _update_brew || return 1
}


