DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install pwsh --no-cache

target="$HOME/scoop/apps/pwsh/current"
install_to_target "$CONFIG_DIR" "$target"
