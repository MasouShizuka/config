DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    scoop install copyq
    target="$HOME/scoop/persist/copyq/config/copyq"
    install_to_target "$CONFIG_DIR" "$target"
fi
