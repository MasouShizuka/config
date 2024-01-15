DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

winget install Neovim.Neovim.Nightly --accept-source-agreements
target="$LOCALAPPDATA/nvim"

clean_target "$target"
install_to_target "$DIR" "$target"
