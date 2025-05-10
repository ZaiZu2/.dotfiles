init_pkg_mgr() {
  sudo apt update || return 1
  info "Updated system packages information"
  sudo apt upgrade --yes || return 1
  sudo apt install --yes cmake curl pkg-config libtool unzip ripgrep \
    build-essential libreadline-dev coreutils || return 1
  info "Upgraded all system packages"
  sudo apt autoremove --yes || return 1
  info "Removed all redundant packages"
}
