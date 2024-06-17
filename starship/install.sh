DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install starship --no-cache
target="$HOME/.config/starship"
clean_target "$target"
install_to_target "$DIR" "$target"
