DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install "$PARENT_DIR/Scoop/config/workspace/tablacus-explorer.json" --no-cache

target="$HOME/scoop/persist/tablacus-explorer"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
