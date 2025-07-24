DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    scoop install yazi

    scoop install bat
    scoop install fd
    scoop install fzf
    scoop install ouch
    scoop install ripgrep

    target="$APPDATA/yazi/config"
    install_to_target "$CONFIG_DIR" "$target"
fi
