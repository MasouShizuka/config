DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((is_windows)); then
    target="$HOME/AppData/Roaming/Rime"
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

# cp -r "$target/cn_dicts" "$CONFIG_DIR"
# cp -r "$target/en_dicts" "$CONFIG_DIR"
# cp -r "$target/lua" "$CONFIG_DIR"
# cp -r "$target/opencc" "$CONFIG_DIR"
# cp -r "$target/others" "$CONFIG_DIR"

# exclusion_list=(".gitignore" "squirrel.yaml" "installation.yaml" "user.yaml")
# for f in "$target"/*; do
#     [[ -e "$f" ]] || break
#
#     if [[ -f $f ]]; then
#         if [[ ! ${exclusion_list[*]} =~ ${f##*/} ]]; then
#             cp "$f" "$CONFIG_DIR"
#         fi
#
#     fi
# done

cp "$target/default.custom.yaml" "$CONFIG_DIR"
cp "$target/weasel.custom.yaml" "$CONFIG_DIR"
cp "$target/custom_phrase_double.txt" "$CONFIG_DIR"
