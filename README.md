# Yorafa Ubuntu Bash Config

Add `~/.local/bin/` to your path first

## Install / update

Run the installer and pick from the menu:

```bash
./install.sh
```

```
  1) Full install    - install packages + configs (asks each step)
  2) Update configs  - re-sync starship / nvim / tmux configs only
  3) Update nvim     - re-sync nvim config only
  4) Update tmux     - re-sync tmux config only
  5) Restore config  - restore a config from a backup (with diff preview)
  6) List backups    - show config backups
  7) Quit
```

Options 2-5 only touch config files, they never install packages. Non-interactive
equivalents (useful for dotfiles managers):

```bash
./install.sh install              # full install
./install.sh update               # all configs
./install.sh update nvim          # nvim config only
./install.sh update tmux          # tmux config only
./install.sh backups              # list backups
./install.sh restore                          # pick config + backup interactively
./install.sh restore nvim                     # pick a backup for nvim
./install.sh restore tmux 20250101-120000      # restore a specific backup
```

### Config backups

Before overwriting anything, the installer copies your current config into this
repo, under `backup/<config>/<timestamp>/` (for example
`backup/nvim/20250101-120000/`). The 5 most recent backups per config are kept,
older ones are pruned. `~/.config/tmux/plugins/` (TPM and its plugins) is never
copied or overwritten.

`backup/` is gitignored, so backups stay local and never get committed.

Since config updates use `rsync --delete`, files you added to `~/.config/nvim`
or `~/.config/tmux` yourself are removed on update - check the backup first if
you had local modifications.

To restore, use menu option 5 (or `./install.sh restore <config> [timestamp]`).
It asks which config and which backup, shows a `diff` of the backup against your
current config (`-` lines get dropped, `+` lines get restored), and only writes
after you confirm. Your current config is backed up again first, so a restore is
undoable too. Set `PREVIEW_LINES` to change how much of the diff is shown
(default 60):

```bash
PREVIEW_LINES=200 ./install.sh restore nvim
```

Or restore by hand:

```bash
cp -r backup/nvim/<timestamp>/. ~/.config/nvim/
```

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
