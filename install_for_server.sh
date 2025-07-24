if [[ ! -x "$(command -v curl)" ]]; then
    echo "curl is required for pulling pre-compiled binaries from git release page"
    echo "Exiting..."
    exit 1
fi

INSTALL_DIR="$HOME/.local/bin"
[[ ! -d $INSTALL_DIR ]] && mkdir -p "$INSTALL_DIR"

DIR=$(dirname "$(readlink -f "$0")")
source "$DIR/lib.sh"

[[ ! -x "$(command -v bat)" ]] && cargo install --locked bat
[[ ! -x "$(command -v fd)" ]] && cargo install fd-find
[[ ! -x "$(command -v ouch)" ]] && cargo install ouch
[[ ! -x "$(command -v rg)" ]] && cargo install ripgrep

# ╭─ bottom ─────────────────────────────────────────────────╮

if [[ ! -x "$(command -v btm)" ]]; then
    cargo install bottom --locked
fi

src="$DIR/bottom/config"
des="$HOME/.config/bottom"
if [[ -d "$src" ]]; then
    install_to_target "$src" "$des"
fi

# ╰───────────────────────────────────────────────── bottom ─╯

# ╭─ fzf ────────────────────────────────────────────────────╮

if [[ ! -x "$(command -v fzf)" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$DIR/.fzf"
    "$DIR/.fzf/install"
    cp "$DIR/.fzf/bin"/* "$INSTALL_DIR"
    rm -rf "$DIR/.fzf"
fi

# ╰──────────────────────────────────────────────────── fzf ─╯

# ╭─ lazygit ────────────────────────────────────────────────╮

if [[ ! -x "$(command -v lazygit)" ]]; then
    download_github_latest "jesseduffield" "lazygit" "$(uname -s)_$(uname -m).tar.gz" "lazygit.tar.gz"
    mkdir -p "$DIR/lazygit/cache"
    tar -xvf "lazygit.tar.gz" -C "$DIR/lazygit/cache"
    mv "$DIR/lazygit/cache/lazygit" "$INSTALL_DIR"
    rm -rf "$DIR/lazygit/cache"
    rm "lazygit.tar.gz"
fi

src="$DIR/lazygit/config"
des="$HOME/.config/lazygit"
if [[ -d "$src" ]]; then
    install_to_target "$src" "$des"

fi

# ╰──────────────────────────────────────────────── lazygit ─╯

# ╭─ neovim ─────────────────────────────────────────────────╮

if [[ ! -x "$(command -v nvim)" ]]; then
    curl -Lo nvim.appimage https://github.com/neovim/neovim-releases/releases/download/stable/nvim-linux-x86_64.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage "$INSTALL_DIR/nvim"
fi

src="$DIR/neovim/config"
des="$HOME/.config/nvim"
if [[ -d "$src" ]]; then
    install_to_target "$src" "$des"
fi

# ╰───────────────────────────────────────────────── neovim ─╯

# ╭─ yazi ───────────────────────────────────────────────────╮

if [[ ! -x "$(command -v yazi)" ]]; then
    cargo install --locked yazi-fm yazi-cli
fi

src="$DIR/yazi/config"
des="$HOME/.config/yazi"
if [[ -d "$src" ]]; then
    install_to_target "$src" "$des"
fi

# ╰─────────────────────────────────────────────────── yazi ─╯

# ╭─ zellij ─────────────────────────────────────────────────╮

if [[ ! -x "$(command -v zellij)" ]]; then
    cargo install --locked zellij
fi

src="$DIR/zellij/config"
des="$HOME/.config/zellij"
if [[ -d "$src" ]]; then
    install_to_target "$src" "$des"
fi

# ╰───────────────────────────────────────────────── zellij ─╯

install_to_target "$DIR/shell/config" "$HOME"
source "$HOME/.bashrc"
