DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install copyq --no-cache
target="$HOME/scoop/persist/copyq/config/copyq"
clean_target "$target"
install_to_target "$DIR" "$target"
