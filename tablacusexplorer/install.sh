DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

CONFIG_DIR="$DIR/config"

scoop install "$PARENT_DIR/scoop/config/workspace/tablacus-explorer.json"

target="$HOME/scoop/persist/tablacus-explorer/addons"
install_to_target "$CONFIG_DIR/addons" "$target"

target="$HOME/scoop/persist/tablacus-explorer/config"
install_to_target "$CONFIG_DIR/config" "$target"
