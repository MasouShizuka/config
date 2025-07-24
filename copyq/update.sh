DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((is_windows)); then
    target="$HOME/scoop/persist/copyq/config/copyq"
fi

if [[ ! -d $target ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR="$DIR/config"

if [[ ! -d $CONFIG_DIR ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

cp "$target/copyq.ini" "$CONFIG_DIR"
cp "$target/copyq-commands.ini" "$CONFIG_DIR"
