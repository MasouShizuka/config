DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

winget install Rime.Weasel --accept-source-agreements

target="$APPDATA/Rime"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
