target="$HOME"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR=$(dirname "$(readlink -f "$0")")/config

shopt -s dotglob

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

cp "$target/.bash_profile" "$CONFIG_DIR"
cp "$target/.bashrc" "$CONFIG_DIR"
