DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install sharex --no-cache
target="$HOME/scoop/persist/sharex/ShareX"
clean_target "$target"
install_to_target "$DIR" "$target"
