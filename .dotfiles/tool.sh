fail() {
  echo 1 >"$CURR_TOOL_STATUS"
  [ "$1" ] && red "$1"
}

finish() {
  echo 0 >"$CURR_TOOL_STATUS"
  [ "$1" ] && green "$1"
}

warn() {
  echo 10 >"$CURR_TOOL_STATUS"
  [ "$1" ] && yellow "$1"
}

parse_tool_line() {
  # Special TOOL log which also carries the error code
  if [[ $1 =~ ^([[:alnum:]]+)\;([[:digit:]]+)\;(.+)$ ]]; then
    local _="${BASH_REMATCH[1]}"
    local status_code="${BASH_REMATCH[2]}"
    local message="${BASH_REMATCH[3]}"
    if [ "$status_code" -eq 0 ]; then # INFO
      echo -e "\033[1;32m┃$message\033[0m"
    elif [ "$status_code" -eq 10 ]; then # WARN
      echo -e "\033[1;33m┃$message\033[0m"
    else # ERROR
      echo -e "\033[1;31m┃$message\033[0m"
    fi
  # Special TOOL end log which means TOOL installation finished
  # elif [[ $1 =~ ^[[:alnum:]]+\;END$ ]]; then

  else
    echo -e "\033[1;32m┃\033[0m$1"
  fi
}

format_line() {
  local status_code=$1
  local message=$2
  if [ $((status_code)) -eq 0 ]; then # INFO
    echo -e "\033[1;32m┃$message\033[0m"
  elif [ $((status_code)) -eq 10 ]; then # WARN
    echo -e "\033[1;33m┃$message\033[0m"
  else # ERROR
    echo -e "\033[1;31m┃$message\033[0m"
  fi
}

process_installation() {
  build_end() {
    local status_code="$(<"$CURR_TOOL_STATUS")"
    if [ $((status_code)) -eq 0 ]; then # INFO
      green "┗━━━━━━━━━"
    elif [ $((status_code)) -eq 10 ]; then # WARN
      yellow "┗━━━━━━━━━"
    else # ERROR
      red "┗━━━━━━━━━"
    fi

  }

  tool="$1"
  install_fn="$2"

  CURR_TOOL="$tool"
  CURR_TOOL_STATUS=$(mktemp) && echo 0 >"$CURR_TOOL_STATUS"
  rm "$LOGS_DIR/$CURR_TOOL.log" &>/dev/null

  local pipe=$(mktemp -u) && mkfifo "$pipe"

  # Background process responsible for live processing individual tool installation logs
  {
    while IFS= read -r line; do
      local status=$(<"$CURR_TOOL_STATUS")
      format_line "$status" "$line"
      # parse_tool_line "$line"
      echo "$line" >>"$LOGS_DIR/$CURR_TOOL.log"
    done <"$pipe"
  } &
  local reader_pid=$!

  blue "┏━━$tool━━━" ""
  # Foreground `install_*` function to which background process listens to
  {
    "$install_fn"
  } >"$pipe"

  wait $reader_pid
  build_end
  return "$(<"$CURR_TOOL_STATUS")"
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
      process_installation "$tool" "$install_fn"
    else
      yellow "$tool" "Skipping - tool is already installed"
    fi
  done
}
