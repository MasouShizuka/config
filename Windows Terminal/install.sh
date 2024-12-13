DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install windows-terminal

target="$HOME/scoop/persist/windows-terminal/settings"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
