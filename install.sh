#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BASHRC="$HOME/.bashrc"

# --- Helpers ---

ask() {
    local prompt="$1"
    local ans
    read -rp "$prompt [y/N]: " ans
    case "$ans" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

add_to_bashrc() {
    local marker="$1"
    local content="$2"
    if ! grep -q "$marker" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "# $marker" >> "$BASHRC"
        echo "$content" >> "$BASHRC"
    fi
}

cmd_exists() {
    command -v "$1" &>/dev/null
}

ensure_bashrc() {
    [ -f "$BASHRC" ] || touch "$BASHRC"
}

# Backups live next to the dotfiles so they are easy to inspect and remove.
# They are gitignored (see .gitignore).
BACKUP_DIR="$DOTFILES_DIR/backup"
BACKUP_KEEP=5
# Max diff lines shown before the restore preview is cut off.
PREVIEW_LINES="${PREVIEW_LINES:-60}"

# backup_dir DST [extra rsync args...]
# Copy the current contents of DST aside before it gets overwritten.
# Skips when DST is missing or empty. Keeps only the newest BACKUP_KEEP backups
# per config so old ones do not pile up.
backup_dir() {
    local dst="$1"
    shift
    [ -d "$dst" ] || return 0
    # Nothing worth saving if the directory has no entries.
    [ -n "$(ls -A "$dst" 2>/dev/null)" ] || return 0

    local name stamp target
    name="$(basename "$dst")"
    stamp="$(date +%Y%m%d-%H%M%S)"
    target="$BACKUP_DIR/$name/$stamp"

    mkdir -p "$target"
    if cmd_exists rsync; then
        rsync -a "$@" "$dst/" "$target/"
    else
        cp -r "$dst/." "$target/"
    fi
    echo "  backup: $target"

    # Prune old backups for this config.
    local old
    while IFS= read -r old; do
        [ -n "$old" ] && rm -rf "$old"
    done < <(find "$BACKUP_DIR/$name" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | tail -n "+$((BACKUP_KEEP + 1))" | cut -d' ' -f2-)
}

# sync_dir SRC DST [extra rsync args...]
# Mirror SRC into DST, backing up DST first. Uses rsync --delete when available
# so files removed from the dotfiles actually disappear from the target.
sync_dir() {
    local src="$1" dst="$2"
    shift 2
    backup_dir "$dst" "$@"
    mkdir -p "$dst"
    if cmd_exists rsync; then
        rsync -a --delete "$@" "$src/" "$dst/"
    else
        cp -r "$src/." "$dst/"
    fi
}

# backup_file PATH - save a single file before it gets overwritten.
# Skips when the file does not exist. Keeps the newest BACKUP_KEEP copies.
backup_file() {
    local path="$1"
    [ -f "$path" ] || return 0
    local name stamp target
    name="$(basename "$path")"
    stamp="$(date +%Y%m%d-%H%M%S)"
    target="$BACKUP_DIR/$name/$stamp"
    mkdir -p "$target"
    cp "$path" "$target/$name"
    echo "  backup: $target/$name"

    local old
    while IFS= read -r old; do
        [ -n "$old" ] && rm -rf "$old"
    done < <(find "$BACKUP_DIR/$name" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | tail -n "+$((BACKUP_KEEP + 1))" | cut -d' ' -f2-)
}

# --- Package installers ---

install_zoxide() {
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    add_to_bashrc "zoxide" 'eval "$(zoxide init bash)"'
    echo "zoxide installed."
}

install_blesh() {
    echo "Installing ble.sh..."
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
    make -C /tmp/ble.sh install PREFIX="$HOME/.local"
    rm -rf /tmp/ble.sh
    add_to_bashrc "ble.sh" 'source -- ~/.local/share/blesh/ble.sh'
    echo "ble.sh installed."
}

install_starship() {
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh
    mkdir -p "$HOME/.config"
    backup_file "$HOME/.config/starship.toml"
    cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
    add_to_bashrc "starship" 'eval "$(starship init bash)"'
    echo "starship installed."
}

install_nvm() {
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    echo "nvm installed (it adds its own lines to .bashrc)."
}

install_neovim() {
    echo "Installing neovim..."
    if cmd_exists nvim; then
        echo "neovim already installed, skipping snap install."
    else
        sudo snap install nvim --classic
    fi
    echo "Copying nvim config..."
    update_nvim_config
    echo "neovim config installed. Run :Lazy on first launch to install plugins."

    if ask "  Install ripgrep (needed by neovim telescope)?"; then
        if cmd_exists rg; then
            echo "ripgrep already installed."
        else
            sudo apt install -y ripgrep
            echo "ripgrep installed."
        fi
    fi
}

install_tmux() {
    echo "Installing tmux..."
    if cmd_exists tmux; then
        echo "tmux already installed."
    else
        sudo apt install -y tmux
    fi
    echo "Copying tmux config..."
    update_tmux_config

    # TPM
    TPM_DIR="$HOME/.config/tmux/plugins/tpm"
    if [ -d "$TPM_DIR" ]; then
        echo "TPM already installed."
    else
        echo "Installing TPM (Tmux Plugin Manager)..."
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
        echo "TPM installed. Run prefix + I inside tmux to install plugins."
    fi
}

install_lazygit() {
    echo "Installing lazygit..."
    if cmd_exists lazygit; then
        echo "lazygit already installed."
    elif cmd_exists go; then
        go install github.com/jesseduffield/lazygit@latest
        echo "lazygit installed via go."
    else
        echo "Go not found, skipping lazygit. Install Go first, then run: go install github.com/jesseduffield/lazygit@latest"
    fi
}

install_uv() {
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installed (it adds its own lines to .bashrc)."
}

install_all() {
    echo "=== Full install ==="
    if ask "Install zoxide (fast directory jumping)?";       then install_zoxide;  fi
    if ask "Install ble.sh (bash line editor)?";             then install_blesh;   fi
    if ask "Install starship (cross-shell prompt)?";         then install_starship; fi
    if ask "Install NVM (Node Version Manager)?";            then install_nvm;     fi
    if ask "Install Neovim + LazyVim config?";               then install_neovim;  fi
    if ask "Install tmux?";                                  then install_tmux;    fi
    if ask "Install lazygit (terminal Git UI)?";             then install_lazygit; fi
    if ask "Install uv (Python manager)?";                   then install_uv;      fi
}

# --- Config updates (no packages installed) ---

update_nvim_config() {
    sync_dir "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "nvim config updated."
}

update_tmux_config() {
    # Keep plugins/ (TPM and its plugins) when mirroring and backing up.
    sync_dir "$DOTFILES_DIR/tmux" "$HOME/.config/tmux" --exclude plugins/
    echo "tmux config updated."
}

update_starship_config() {
    mkdir -p "$HOME/.config"
    backup_file "$HOME/.config/starship.toml"
    cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
    echo "starship config updated."
}

update_all_configs() {
    echo "=== Updating all configs ==="
    update_starship_config
    update_nvim_config
    update_tmux_config
}

list_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "No backups found ($BACKUP_DIR does not exist)."
        return 0
    fi
    echo "=== Backups in $BACKUP_DIR ==="
    echo "=== (gitignored, remove old ones freely) ==="
    # Each backup dir is named <config>/<YYYYmmdd-HHMMSS>; sort on that stamp.
    find "$BACKUP_DIR" -mindepth 2 -maxdepth 2 -type d -printf '%f %p\n' 2>/dev/null \
        | sort -r | while IFS=' ' read -r stamp path; do
            echo "  $stamp  $path"
        done
}

# --- Restore from backups ---

# config_target NAME - where NAME is restored to. Echoes "path <is_file>".
config_target() {
    case "$1" in
        nvim)          echo "$HOME/.config/nvim 0" ;;
        tmux)          echo "$HOME/.config/tmux 0" ;;
        starship.toml) echo "$HOME/.config/starship.toml 1" ;;
        *)             return 1 ;;
    esac
}

# restore_backup NAME STAMP - put backup/NAME/STAMP back in place.
# The current config is backed up first, so a restore is undoable too.
restore_backup() {
    local name="$1" stamp="$2"
    local src="$BACKUP_DIR/$name/$stamp"
    [ -d "$src" ] || { echo "Backup not found: $src" >&2; return 1; }

    local target is_file
    read -r target is_file <<< "$(config_target "$name")"

    if [ "$is_file" = "1" ]; then
        backup_file "$target"
        mkdir -p "$(dirname "$target")"
        cp "$src/$name" "$target"
    else
        # Back up current config, then mirror the backup over it.
        local exclude=()
        [ "$name" = "tmux" ] && exclude=(--exclude plugins/)
        backup_dir "$target" "${exclude[@]+"${exclude[@]}"}"
        mkdir -p "$target"
        if cmd_exists rsync; then
            rsync -a --delete "${exclude[@]+"${exclude[@]}"}" "$src/" "$target/"
        else
            cp -r "$src/." "$target/"
        fi
    fi
    echo "restored $name from backup $stamp"
}

# preview_restore NAME SRC TARGET IS_FILE - show what restoring would change.
# Printed as a unified diff from the current config towards the backup, so
# "+" lines are what you get back and "-" lines are what gets dropped.
preview_restore() {
    local name="$1" src="$2" target="$3" is_file="$4"
    local args=()
    if [ "$is_file" != "1" ] && [ "$name" = "tmux" ]; then
        args=(--exclude plugins/)
    fi

    if ! cmd_exists diff; then
        echo "  (diff not available, skipping preview)"
        return 0
    fi

    local before="$target"
    [ "$is_file" = "1" ] && before="$src/$name"

    if [ ! -e "$before" ]; then
        echo "  (nothing to compare against, restore will create everything)"
        find "$src" -type f -printf '  + %P\n' 2>/dev/null || true
        return 0
    fi

    local out rc=0
    if [ "$is_file" = "1" ]; then
        out="$(diff -u "$target" "$src/$name" 2>&1)" || rc=$?
    else
        out="$(diff -ru "${args[@]+"${args[@]}"}" "$target" "$src" 2>&1)" || rc=$?
    fi

    if [ "$rc" -gt 1 ]; then
        echo "  (preview failed: ${out%%$'\n'*})"
    elif [ -z "$out" ]; then
        echo "  (no differences, backup matches current config)"
    else
        # Keep the preview readable; report if it was cut off.
        local total lines
        total="$(printf '%s\n' "$out" | wc -l)"
        lines="$PREVIEW_LINES"
        printf '%s\n' "$out" | head -n "$lines"
        if [ "$total" -gt "$lines" ]; then
            echo "  ... ($((total - lines)) more diff lines hidden)"
        fi
    fi
}

# restore_config [NAME] [STAMP] - restore a config, asking which backup to use.
# Both arguments are optional; STAMP defaults to the newest backup.
restore_config() {
    local name="${1:-}" stamp="${2:-}"

    if [ -z "$name" ]; then
        echo "  1) nvim"
        echo "  2) tmux"
        echo "  3) starship.toml"
        echo "  0) Cancel"
        local pick
        read -rp "  Select config [1-3]: " pick
        case "$pick" in
            1) name=nvim ;;
            2) name=tmux ;;
            3) name=starship.toml ;;
            *) echo "Cancelled."; return 0 ;;
        esac
    fi

    local target is_file
    if ! target="$(config_target "$name")"; then
        echo "Unknown config: $name (expected nvim, tmux or starship.toml)" >&2
        return 1
    fi
    read -r target is_file <<< "$target"

    if [ ! -d "$BACKUP_DIR/$name" ]; then
        echo "No backups for $name in $BACKUP_DIR." >&2
        return 1
    fi

    if [ -z "$stamp" ]; then
        local stamps=() i=1 choice
        while IFS= read -r choice; do
            stamps+=("$choice")
            echo "  $i) $choice"
            i=$((i + 1))
        done < <(find "$BACKUP_DIR/$name" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort -r)

        if [ "${#stamps[@]}" -eq 0 ]; then
            echo "No backups for $name in $BACKUP_DIR/$name." >&2
            return 1
        fi

        read -rp "  Select backup [1-${#stamps[@]}, Enter=cancel]: " choice
        [ -z "$choice" ] && { echo "Cancelled."; return 0; }
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#stamps[@]}" ]; then
            echo "Invalid choice: $choice" >&2
            return 1
        fi
        stamp="${stamps[$((choice - 1))]}"
    fi

    echo "  Restore $name from backup $stamp"
    echo "  Preview (- = removed, + = restored):"
    preview_restore "$name" "$BACKUP_DIR/$name/$stamp" "$target" "$is_file"
    ask "  Apply this restore?" || { echo "Cancelled."; return 0; }
    restore_backup "$name" "$stamp"
}

# --- Menu ---

menu() {
    echo "=== Yorafa Dotfiles ==="
    echo ""
    echo "  1) Full install    - install packages + configs (asks each step)"
    echo "  2) Update configs  - re-sync starship / nvim / tmux configs only"
    echo "  3) Update nvim     - re-sync nvim config only"
    echo "  4) Update tmux     - re-sync tmux config only"
    echo "  5) Restore config - restore a config from a backup"
    echo "  6) List backups    - show config backups"
    echo "  7) Quit"
    echo ""
    echo "  Updating a config backs up your current one to $BACKUP_DIR"
    echo ""
    local choice
    read -rp "Select [1-7]: " choice
    case "$choice" in
        1) install_all ;;
        2) update_all_configs ;;
        3) update_nvim_config ;;
        4) update_tmux_config ;;
        5) restore_config ;;
        6) list_backups ;;
        7|q|Q|"") echo "Bye."; exit 0 ;;
        *) echo "Invalid choice: $choice"; exit 1 ;;
    esac
}

# --- Init ---

ensure_bashrc

# Ensure ~/.local/bin is in PATH and .bashrc
export PATH="$HOME/.local/bin:$PATH"
add_to_bashrc "dotfiles-local-bin" 'export PATH="$HOME/.local/bin:$PATH"'

# Non-interactive usage:
#   ./install.sh                 -> menu
#   ./install.sh install         -> full install
#   ./install.sh update [all|nvim|tmux]
#   ./install.sh backups         -> list config backups
#   ./install.sh restore [nvim|tmux|starship.toml] [timestamp]
case "${1:-menu}" in
    menu)     menu ;;
    install)  install_all ;;
    backups)  list_backups ;;
    restore)  restore_config "${2:-}" "${3:-}" ;;
    update)
        case "${2:-all}" in
            all)  update_all_configs ;;
            nvim) update_nvim_config ;;
            tmux) update_tmux_config ;;
            *) echo "Usage: $0 update [all|nvim|tmux]" >&2; exit 1 ;;
        esac
        ;;
    -h|--help|help)
        echo "Usage: $0 [menu|install|update [all|nvim|tmux]|backups]"
        echo "       $0 restore [nvim|tmux|starship.toml] [timestamp]"
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo "Usage: $0 [menu|install|update [all|nvim|tmux]|backups]" >&2
        echo "       $0 restore [nvim|tmux|starship.toml] [timestamp]" >&2
        exit 1
        ;;
esac

echo ""
echo "=== Done! Restart your shell or run: source ~/.bashrc ==="
