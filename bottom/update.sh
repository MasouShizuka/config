target="$APPDATA/bottom"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR=$(dirname "$(readlink -f "$0")")/config

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

cp "$target/bottom.toml" "$CONFIG_DIR"
