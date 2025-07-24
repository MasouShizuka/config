DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    scoop install neovim
    scoop install nodejs
    scoop install "$PARENT_DIR/scoop/config/workspace/im-select.json"
    target="$LOCALAPPDATA/nvim"
    install_to_target "$CONFIG_DIR" "$target"
fi
