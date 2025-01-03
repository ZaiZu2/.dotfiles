export XDG_CONFIG_HOME="$HOME/.config"
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export PATH="$XDG_BIN_HOME:/bin:/usr/bin:/usr/local/bin:$PATH"
export PATH="/usr/local/go:$XDG_DATA_HOME/cargo/bin:$PATH"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"

export ZK_NOTEBOOK_DIR="$HOME/Notes"

export EDITOR=nvim
export VISUAL=nvim

command -v brew > /dev/null 2>&1 && brew shellenv | bash -s
