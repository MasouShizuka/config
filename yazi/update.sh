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

exclusion_list=("flavors" "plugins" "package.toml")
for f in "$target"/*; do
    [[ -e "$f" ]] || break

    name=${f##*/}
    if [[ ! ${exclusion_list[*]} =~ $name ]]; then
        cp -r "$f" "$CONFIG_DIR"
    fi
done

shopt -s dotglob

mkdir "$CONFIG_DIR/flavors"
exclusion_flavor_list=("catppuccin-macchiato.yazi")
for d in "$target/flavors"/*; do
    [[ -e "$d" ]] || break

    flavor_name=${d##*/}
    if [[ ! ${exclusion_flavor_list[*]} =~ $flavor_name ]]; then
        cp -r "$d" "$CONFIG_DIR/flavors"
    fi
done

mkdir "$CONFIG_DIR/plugins"
exclusion_plugin_list=("yatline.yazi" "close-and-restore-tab.yazi" "projects.yazi" "full-border.yazi" "git.yazi" "mime-ext.yazi" "smart-enter.yazi")
exclusion_list=(".git" ".github" ".gitignore")
for d in "$target/plugins"/*; do
    [[ -e "$d" ]] || break

    plugin_name=${d##*/}
    if [[ ${exclusion_plugin_list[*]} =~ $plugin_name ]]; then
        continue
    fi

    mkdir "$CONFIG_DIR/plugins/$plugin_name"
    for f in "$target/plugins/$plugin_name"/*; do
        [[ -e "$f" ]] || break

        name=${f##*/}
        if [[ ! ${exclusion_list[*]} =~ $name ]]; then
            cp -r "$f" "$CONFIG_DIR/plugins/$plugin_name"
        fi
    done
done
