DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    scoop install "$PARENT_DIR/Scoop/config/workspace/picview.json"
    target="$HOME/scoop/persist/picview/Config"
    clean_target "$target"
    install_to_target "$CONFIG_DIR" "$target"
fi
