DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((is_windows)); then
    target="$APPDATA/yazi/config"
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

exclusion_list=("plugins")
for f in "$target"/*; do
    [[ -e "$f" ]] || break

    name=${f##*/}
    if [[ ! ${exclusion_list[*]} =~ $name ]]; then
        cp -r "$f" "$CONFIG_DIR"
    fi
done

shopt -s dotglob

mkdir "$CONFIG_DIR/plugins"
exclusion_list=(".git" ".github" ".gitignore")
for d in "$target/plugins"/*; do
    [[ -e "$d" ]] || break

    plugin_name=${d##*/}
    mkdir "$CONFIG_DIR/plugins/$plugin_name"

    for f in "$target/plugins/$plugin_name"/*; do
        [[ -e "$f" ]] || break

        name=${f##*/}
        if [[ ! ${exclusion_list[*]} =~ $name ]]; then
            cp -r "$f" "$CONFIG_DIR/plugins/$plugin_name"
        fi
    done
done
