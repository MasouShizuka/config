DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install mpv-git

target="$HOME/scoop/persist/mpv-git/portable_config"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
