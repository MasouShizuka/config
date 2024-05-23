DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

winget install ShareX.ShareX --accept-source-agreements
target="$HOME/Documents/ShareX"
clean_target "$target"
install_to_target "$DIR" "$target"
