_update_apt() {
  apt update || return 1
  apt upgrade
  apt install cmake curl pkg-config libtool unzip ripgrep \
    build-essential libreadline-dev gnu-tar coreutils
}

init_pkg_mgr() {
  _update_apt || return 1
}
