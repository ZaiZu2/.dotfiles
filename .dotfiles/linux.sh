init_pkg_mgr() {
  sudo apt update || return 1
  green "Updated system packages greenrmation"
  sudo apt upgrade --yes || return 1
  sudo apt install --yes cmake curl pkg-config libtool unzip ripgrep \
    build-essential libreadline-dev coreutils || return 1
  green "Upgraded all system packages"
  sudo apt autoremove --yes || return 1
  green "Removed all redundant packages"
}

install_font() {
  sudo cp "$SCRIPT_DIR/files/font/"* /usr/share/fonts
  sudo chmod 644 /usr/share/fonts/*
  green "Installed fonts"
}
