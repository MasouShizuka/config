DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install wezterm --no-cache
target="$HOME/.config/wezterm"
clean_target "$target"
install_to_target "$DIR" "$target"
