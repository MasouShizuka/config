DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install "$PARENT_DIR/Scoop/config/workspace/mykeymap.json"

target="$HOME/scoop/persist/mykeymap"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
