is_windows=0
is_mac=0
is_linux=0
is_wsl=0
uname=$(uname -a | tr '[:upper:]' '[:lower:]')
case "$uname" in
mingw*)
    is_windows=1
    ;;
*msys)
    is_windows=1
    ;;
darwin*)
    is_mac=1
    ;;
*wsl*)
    is_linux=1
    is_wsl=1
    ;;
linux*)
    is_linux=1
    ;;
esac

clean_target() {
    target=$1

    if [[ -d "$target" ]]; then
        backup="$target"_bak_"$(date "+%Y-%m-%d-%H-%M-%S")"
        echo "备份已有的 $target" 到 "$backup"
        mv "$target" "$backup"
    fi

    mkdir -p "$target"
}

install_to_target() {
    source=$1
    target=$2

    if [[ ! -d "$target" ]]; then
        mkdir -p "$target"
    fi

    shopt -s dotglob

    echo "复制配置到 $target"
    exclusion_list=("README.md" "install.sh" "update.sh")
    for f in "$source"/*; do
        [[ -e "$f" ]] || break

        name=${f##*/}
        if [[ ! ${exclusion_list[*]} =~ $name ]]; then
            cp -rf "$f" "$target"
        fi
    done
}

download_github_latest() {
    author=$1
    repo=$2
    file=$3
    output=$4

    curl -kL -o "$output" "$(curl -ks "https://api.github.com/repos/$author/$repo/releases/latest" | grep "browser_download_url" | cut -d \" -f 4 | grep "$file")"
}

execute_scripts_of_subdirectories() {
    parent_dir=$1
    script_name=$2
    description=$3

    for d in "$parent_dir"/*; do
        if [[ -d $d ]]; then
            name=${d##*/}
            cd "$d" || continue

            if [[ -f $script_name ]]; then
                echo "开始：$name $description"
                sh "$script_name"
                echo "结束：$name $description"
                echo "----------------------------------------"
            fi

            cd "$DIR" || continue
        fi
    done
}
