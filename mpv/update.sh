DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((is_windows)); then
    target="$HOME/scoop/persist/mpv-git/portable_config"
fi

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR="$DIR/config"

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

cp -r "$target/fonts" "$CONFIG_DIR"
cp -r "$target/scripts" "$CONFIG_DIR"
cp -r "$target/script-opts" "$CONFIG_DIR"
cp -r "$target/shaders" "$CONFIG_DIR"
cp -r "$target/vs" "$CONFIG_DIR"

cp "$target/input.conf" "$CONFIG_DIR"
cp "$target/mpv.conf" "$CONFIG_DIR"
