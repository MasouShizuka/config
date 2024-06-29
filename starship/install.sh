DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install starship --no-cache
target="$HOME/.config/starship"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
