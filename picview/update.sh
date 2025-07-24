DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((is_windows)); then
    target="$HOME/scoop/persist/picview/Config"
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

cp "$target/UserSettings.json" "$CONFIG_DIR"
cp "$target/keybindings.json" "$CONFIG_DIR"

sed -i "s/\(\"Top\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/UserSettings.json"
sed -i "s/\(\"Left\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/UserSettings.json"
sed -i "s/\(\"Width\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/UserSettings.json"
sed -i "s/\(\"Height\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/UserSettings.json"
sed -i "s/\(\"LastFile\":\s*\)[^}]*\([,}]\)/\1\"\"\2/g" "$CONFIG_DIR/UserSettings.json"
unix2dos "$CONFIG_DIR/UserSettings.json"
