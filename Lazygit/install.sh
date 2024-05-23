DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

winget install JesseDuffield.lazygit --accept-source-agreements
target="$LOCALAPPDATA/lazygit"
clean_target "$target"
install_to_target "$DIR" "$target"
