DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((is_windows)); then
    target="$HOME/scoop/persist/vscode/data/user-data/User"
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

cp -r "$target/snippets" "$CONFIG_DIR"

cp "$target/settings.json" "$CONFIG_DIR"
# jq --indent 4 'with_entries(if .key == "sshfs.configs" then . + {"value": []} else . end)' "$CONFIG_DIR/User/settings.json" >"$DIR/temp.json"
# mv "$DIR/temp.json" "$CONFIG_DIR/User/settings.json"
unix2dos "$CONFIG_DIR/settings.json"

cp "$target/keybindings.json" "$CONFIG_DIR"
