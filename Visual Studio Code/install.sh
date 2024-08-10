DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install vscode --no-cache

target="$HOME/scoop/persist/vscode/data/user-data"
install_to_target "$CONFIG_DIR" "$target"
