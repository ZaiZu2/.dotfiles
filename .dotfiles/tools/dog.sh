is_installed_dog() {
  command -v dog >/dev/null 2>&1
}

install_linux() {
  echo "$SCRIPT_DIR/utils.sh"
  source "$SCRIPT_DIR/utils.sh"
  echo 'dog'
  echo 'cat'
  echo 'bat'
  info 'poop' 'poop'
  error 'poop' 'poop'
}

install_darwin() {

  echo 'dog'
  echo 'cat'
  echo 'bat'
}

install_dog() {
  if [ "$OS" = 'darwin' ]; then
    install_darwin || return 1
  elif [ "$OS" = 'linux' ]; then
    install_linux || return 1
  fi
  return 1
}
