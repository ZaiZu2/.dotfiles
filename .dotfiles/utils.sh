info() {
  if [ $# -ge 2 ]; then
    echo -e "\033[1;32m[$1]\033[0m ${*:2}"
  else
    echo -e "\033[1;32m[INFO]\033[0m $1"
  fi
}

error() {
  if [ $# -ge 2 ]; then
    echo -e "\033[1;31m[$1]\033[0m ${*:2}"
  else
    echo -e "\033[1;31m[ERROR]\033[0m $1"
  fi
}

warn() {
  if [ $# -ge 2 ]; then
    echo -e "\033[1;33m[$1]\033[0m ${*:2}"
  else
    echo -e "\033[1;33m[WARN]\033[0m $1"
  fi
}

check_fn() {
  for fn in "${@:2}"; do
    if ! declare -f "$fn" >/dev/null; then
      error "$1" "Function '$fn' does not exist"
      return 1
    fi
  done
}
