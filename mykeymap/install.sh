DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

CONFIG_DIR="$DIR/config"

scoop install "$PARENT_DIR/scoop/config/workspace/mykeymap.json"

target="$HOME/scoop/persist/mykeymap"
install_to_target "$CONFIG_DIR" "$target"
