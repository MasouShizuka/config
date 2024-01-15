DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

winget install hluk.CopyQ --accept-source-agreements
target="$APPDATA/copyq"

clean_target "$target"
install_to_target "$DIR" "$target"
