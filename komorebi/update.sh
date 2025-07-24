DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

target="$HOME/.config/komorebi"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR="$DIR/config"

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

# shopt -s dotglob
#
# mkdir "$CONFIG_DIR/komorebi"
# exclusion_list=(".git" ".github" ".gitignore" "target")
# for f in "$target/komorebi"/{*,.[!.]*}; do
#     [[ -e "$f" ]] || break
#
#     name=${f##*/}
#     if [[ ! ${exclusion_list[*]} =~ $name ]]; then
#         cp -r "$f" "$CONFIG_DIR/komorebi"
#     fi
# done

mkdir -p "$CONFIG_DIR/komorebi/komorebi/src"
cp "$target/komorebi/komorebi/src/focus_manager.rs" "$CONFIG_DIR/komorebi/komorebi/src"
cp "$target/komorebi/komorebi/src/monitor.rs" "$CONFIG_DIR/komorebi/komorebi/src"
cp "$target/komorebi/komorebi/src/process_command.rs" "$CONFIG_DIR/komorebi/komorebi/src"
cp "$target/komorebi/komorebi/src/process_event.rs" "$CONFIG_DIR/komorebi/komorebi/src"
cp "$target/komorebi/komorebi/src/window_manager.rs" "$CONFIG_DIR/komorebi/komorebi/src"

mkdir -p "$CONFIG_DIR/komorebi/komorebi-bar/src/widgets"
cp "$target/komorebi/komorebi-bar/src/widgets/komorebi.rs" "$CONFIG_DIR/komorebi/komorebi-bar/src/widgets"
cp "$target/komorebi/komorebi-bar/src/widgets/media.rs" "$CONFIG_DIR/komorebi/komorebi-bar/src/widgets"
cp "$target/komorebi/komorebi-bar/src/widgets/network.rs" "$CONFIG_DIR/komorebi/komorebi-bar/src/widgets"

cp "$target/komorebi.json" "$CONFIG_DIR"
cp "$target/komorebi.bar.json" "$CONFIG_DIR"
cp "$target/komorebi.bar2.json" "$CONFIG_DIR"
cp "$target/komorebi.bar3.json" "$CONFIG_DIR"
cp "$target/komorebi.ahk" "$CONFIG_DIR"
cp "$target/applications.json" "$CONFIG_DIR"
