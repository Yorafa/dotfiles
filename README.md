# Yorafa Ubuntu Config

## fzf

use `C-t` after binary exectuable to fast select file

use `A-c` to fast cd

use `fzf` to fast locate target file

install by

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

update by

```bash
cd ~/.fzf
git fetch && git pull && ./install
```

## Z

Use [zoxide](https://github.com/ajeetdsouza/zoxide) to fast jump to your most recent use dir, install by

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

## bashrc

Some commands might raise error since uninstall, follow install steps below

### powerline status

[starship](https://starship.rs/) which is a cross-shell prompt,

``` bash
curl -sS https://starship.rs/install.sh | sh
cp ./starship.toml ~/.config/starship.toml
```

### Node Version Manage

install [NVM](https://github.com/nvm-sh/nvm) by

``` bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

update it by

```bash
cd ~/.nvm
git fetch  && git pull
```

### SDKMAN

install [SDEKMAN!](https://sdkman.io/) to manage multiple different versions of SDKs (mainly JAVA related) by

```bash
curl -s "https://get.sdkman.io" | bash
```

update it by

```bash
sdk selfupdate force
```

## Neovim

Use [LazyVim](https://www.lazyvim.org/) with [craftzdog's Config](https://github.com/craftzdog/dotfiles-public)

Install neovim by

```bash
sudo snap install nvim --classic
```

copy the `nvim` folder into `~/.config/nvim`

### Lazy.Vim

Use to install plugin, configuration files under `~/.local/share/nvim/lazy/LazyVim/`. All other plugins are also under this directory.

## tmux

Change default prefix from `C-b` to `C-d`, use prefix and then `?` to look the help manual

## UV

All in one python managerment. Include but not only manager different version of python, different venvs, and so on. Install:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```
