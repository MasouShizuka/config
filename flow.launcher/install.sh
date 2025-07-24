DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

CONFIG_DIR="$DIR/config"

scoop install flow-launcher

scoop install mambaforge
scoop install everything-alpha
echo "NOTE: Set alpha_instance to false to made it possible for Everything 1.5a to work with the Flow.Launcher."

target="$HOME/scoop/persist/flow-launcher/UserData"
install_to_target "$CONFIG_DIR" "$target"
