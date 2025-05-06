if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Personal Alias
alias clangd='clangd-14'

# Default  Editor
set -gx EDITOR nvim

# Binary Excutable Path
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

# Greeting Message

set fish_greeting "早上好，中午好，晚上好

每天和lff、mmm过得开开心心uwu
"
