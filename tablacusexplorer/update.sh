DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

target="$HOME/scoop/persist/tablacus-explorer"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR="$DIR/config"

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

mkdir "$CONFIG_DIR/addons"
cp -r "$target/addons/addonsupdater" "$CONFIG_DIR/addons"
cp -r "$target/addons/countbar" "$CONFIG_DIR/addons"
cp -r "$target/addons/darkmode" "$CONFIG_DIR/addons"
cp -r "$target/addons/foldersettings" "$CONFIG_DIR/addons"
cp -r "$target/addons/font" "$CONFIG_DIR/addons"
cp -r "$target/addons/preview" "$CONFIG_DIR/addons"
cp -r "$target/addons/shellexecutehook" "$CONFIG_DIR/addons"
cp -r "$target/addons/sizestatus" "$CONFIG_DIR/addons"
cp -r "$target/addons/showhash" "$CONFIG_DIR/addons"
cp -r "$target/addons/tabposition" "$CONFIG_DIR/addons"

mkdir "$CONFIG_DIR/config"
cp "$target/config/addons.xml" "$CONFIG_DIR/config"
cp "$target/config/foldersettings.xml" "$CONFIG_DIR/config"
cp "$target/config/key.xml" "$CONFIG_DIR/config"
cp "$target/config/window.xml" "$CONFIG_DIR/config"
