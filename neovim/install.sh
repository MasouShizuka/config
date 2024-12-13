DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install neovim
scoop install "$PARENT_DIR/Scoop/config/workspace/im-select.json"

target="$LOCALAPPDATA/nvim"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
