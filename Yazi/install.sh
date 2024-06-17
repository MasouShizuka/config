DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install yazi --no-cache

scoop install fd --no-cache
scoop install fzf --no-cache
scoop install jq --no-cache
scoop install ouch --no-cache
scoop install ripgrep --no-cache

target="$APPDATA/yazi"
clean_target "$target"
install_to_target "$DIR" "$target"
