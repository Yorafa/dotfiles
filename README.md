# Yorafa Ubuntu Bash Config

Add `~/.local/bin/` to your path first

## Z

Use [zoxide](https://github.com/ajeetdsouza/zoxide) to fast jump to your most recent use dir, install by

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

And setup by adding this to the end of config `~/.bashrc`

```bash
eval "$(zoxide init bash)"
```

## bash line editor (ble.sh)

[ble.sh](https://github.com/akinomyoga/ble.sh) is an editor that supports syntax highlighting, enhanced completion. install by

```bash
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source -- ~/.local/share/blesh/ble.sh' >> ~/.bashrc
```

## powerline status

[starship](https://starship.rs/) which is a cross-shell prompt,

``` bash
curl -sS https://starship.rs/install.sh | sh
cp ./starship.toml ~/.config/starship.toml
```

## Node Version Manage

install [NVM](https://github.com/nvm-sh/nvm) by

``` bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

update it by

```bash
cd ~/.nvm
git fetch  && git pull
```

## Neovim

Use [LazyVim](https://www.lazyvim.org/)

Install neovim by

```bash
sudo snap install nvim --classic
```

copy the `nvim` folder into `~/.config/nvim`

### Lazy.Vim

Use to install plugin, configuration files under `~/.local/share/nvim/lazy/LazyVim/`. All other plugins are also under this directory.

Some extra needs to be installed:
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation): use for recursively searching the cwd

## tmux

Install:

```bash
sudo apt install tmux
```

### tpm

Tmux Plugin Manager, install by

```bash
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```


## UV

All in one python managerment. Include but not only manager different version of python, different venvs, and so on. Install:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## LazyGit

Use go to install lazygit.

```bash
go install github.com/jesseduffield/lazygit@latest
```
