DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install wezterm

target="$HOME/.config/wezterm"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
