export XDG_CONFIG_HOME="$HOME/.config"
export PATH="$PATH:/opt/nvim-linux64/bin"

# Add fly.io CLI
export FLYCTL_INSTALL="/home/jakub/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
FZF_DEFAULT_OPTS='--height 40% --border'

for file in ~/.bash/.bash_git ~/.bash/.bash_prompt ~/.bash/.bash_completions; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done
unset file;
