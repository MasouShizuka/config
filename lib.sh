PORTABLE_DIR=/d/Tools

clean_target() {
    target=$1

    echo "删除已有的 $target"
    if [[ -d "$target" ]]; then
        rm -rf "$target"
    fi
}

install_to_target() {
    source=$1
    target=$2

    if [[ ! -d "$target" ]]; then
        mkdir -p "$target"
    fi

    echo "复制配置到 $target"
    exclusion_list=("README.md" "install.sh" "update.sh")
    for f in "$source"/*; do
        [[ -e "$f" ]] || break

        name=${f##*/}
        if [[ ! ${exclusion_list[*]} =~ $name ]]; then
            cp -r "$f" "$target"
        fi
    done
}

download_github_latest() {
    author=$1
    repo=$2
    file=$3
    output=$4

    curl -kL -o "$output"  "$(curl -ks "https://api.github.com/repos/$author/$repo/releases/latest" | grep "browser_download_url" | cut -d \" -f 4 | grep "$file")"
}
