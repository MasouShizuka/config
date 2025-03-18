DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    scoop install starship
fi

target="$HOME/.config/starship"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
