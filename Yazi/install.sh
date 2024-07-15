DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install yazi --no-cache

scoop install bat --no-cache
scoop install fd --no-cache
scoop install fzf --no-cache
scoop install ouch --no-cache
scoop install ripgrep --no-cache

target="$APPDATA/yazi"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
