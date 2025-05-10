info() {
  if [ $# -ge 2 ]; then
    echo -e "\033[1;32m[$1]\033[1;34m ${*:2}\033[0m"
  else
    echo -e "\033[1;32m[INFO]\033[1;34m $1\033[0m"
  fi
}

error() {
  if [ $# -ge 2 ]; then
    echo -e "\033[1;31m[$1]\033[1;34m ${*:2}\033[0m"
  else
    echo -e "\033[1;31m[ERROR]\033[1;34m $1\033[0m"
  fi
}

warn() {
  if [ $# -ge 2 ]; then
    echo -e "\033[1;33m[$1]\033[1;34m ${*:2}\033[0m"
  else
    echo -e "\033[1;33m[WARN]\033[1;34m $1\033[0m"
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

create_tool_template() {
  tool_name=$1
  tool_path=$(realpath "./tools/$tool_name.sh")
  if [ -f "$tool_path" ]; then
    error "$tool_name" "Template not created - tool already exists"
    return 1
  fi

  touch "$tool_path"
  # Tabs with `-EOF` allow to indent here-doc without injecting indentation into file
  cat >"./tools/${tool_name}.sh" <<-EOF
	is_installed_${tool_name}() {
	  command -v ${tool_name} >/dev/null 2>&1;
	}

	install_${tool_name}() {
	  if [ "\$OS" = 'darwin' ]; then
	    
	  elif [ "\$OS" = 'linux' ]; then
	    
	  fi
	}
	EOF
  chmod +x "$tool_path"
  info "$tool_name" "Template created at $tool_path"
}
