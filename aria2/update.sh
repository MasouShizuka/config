target="$HOME/.config/aria2"

if [[ ! -d "$target" ]]; then
    echo "设置不存在"
    exit 1
fi

CONFIG_DIR=$(dirname "$(readlink -f "$0")")/config

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi
rm -rf "${CONFIG_DIR:?}"/*

cp -r "$target/aria2_python" "$CONFIG_DIR"

shopt -s dotglob

mkdir "$CONFIG_DIR/aria2_rust"
exclusion_list=(".git" ".github" ".gitignore" "target")
for f in "$target/aria2_rust"/*; do
    [[ -e "$f" ]] || break

    name=${f##*/}
    if [[ ! ${exclusion_list[*]} =~ $name ]]; then
        cp -r "$f" "$CONFIG_DIR/aria2_rust"
    fi
done

cp "$target/aria2.sh" "$CONFIG_DIR"
cp "$target/script.conf" "$CONFIG_DIR"
cp "$target/core" "$CONFIG_DIR"
cp "$target/clean.sh" "$CONFIG_DIR"
cp "$target/delete.sh" "$CONFIG_DIR"
cp "$target/tracker.sh" "$CONFIG_DIR"
cp "$target/AriaNg.ico" "$CONFIG_DIR"

cp "$target/aria2.conf" "$CONFIG_DIR"
sed -i "s/^\(bt-tracker=\).*/\1/" "$CONFIG_DIR/aria2.conf"
