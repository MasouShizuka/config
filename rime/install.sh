DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    winget install Rime.Weasel --accept-source-agreements
    target="$APPDATA/Rime"
    rm -rf "$target"
    git clone https://github.com/iDvel/rime-ice.git "$target" --depth 1
    cd "$target"
    git pull
    install_to_target "$CONFIG_DIR" "$target"
fi
