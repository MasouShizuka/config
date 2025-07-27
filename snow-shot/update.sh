DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

target="$HOME/scoop/persist/snow-shot/configs"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR="$DIR/config"

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

cp "$target/appFunction.json" "$CONFIG_DIR"
cp "$target/functionFixedContent.json" "$CONFIG_DIR"
cp "$target/functionScreenshot.json" "$CONFIG_DIR"
cp "$target/KeyEvent.json" "$CONFIG_DIR"
