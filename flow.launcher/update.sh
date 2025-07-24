DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

target="$HOME/scoop/persist/flow-launcher/UserData"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR="$DIR/config"

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

mkdir -p "$CONFIG_DIR/Plugins"
mkdir -p "$CONFIG_DIR/Settings"

cp -r "$target/Plugins/Neovim Session Manager" "$CONFIG_DIR/Plugins"

cp -r "$target/Settings/Plugins" "$CONFIG_DIR/Settings"
for d in "$CONFIG_DIR/Settings/Plugins"/*; do
    [[ -e "$d" ]] || break

    if [[ -d $d ]]; then
        rm "$d"/*.bak
    fi
done
sed -i "s/\(\"LastIndexTime\":\s*\)[^,}]*\([,}]\?\)/\1\"1970-01-01T00:00:00+08:00\"\2/" "$CONFIG_DIR/Settings/Plugins/Flow.Launcher.Plugin.Program/Settings.json"
unix2dos "$CONFIG_DIR/Settings/Plugins/Flow.Launcher.Plugin.Program/Settings.json"

cp -r "$target/Themes" "$CONFIG_DIR"

cp "$target/Settings/Settings.json" "$CONFIG_DIR/Settings"
sed -i "s/\(\"SettingWindowWidth\":\s*\)[^,}]*\([,}]\?\)/\11200\2/g" "$CONFIG_DIR/Settings/Settings.json"
sed -i "s/\(\"SettingWindowHeight\":\s*\)[^,}]*\([,}]\?\)/\1800\2/g" "$CONFIG_DIR/Settings/Settings.json"
sed -i "s/\(\"SettingWindowTop\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/Settings/Settings.json"
sed -i "s/\(\"SettingWindowLeft\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/Settings/Settings.json"
sed -i "s/\(\"WindowLeft\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/Settings/Settings.json"
sed -i "s/\(\"WindowTop\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/Settings/Settings.json"
sed -i "s/\(\"ActivateTimes\":\s*\)[^,}]*\([,}]\?\)/\10\2/g" "$CONFIG_DIR/Settings/Settings.json"
unix2dos "$CONFIG_DIR/Settings/Settings.json"
