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

check_and_cd() {
    if [[ -f "$1" ]]; then
        dir=$(dirname "$1")
        cd "$dir" || return 1
        return 0
    elif [[ -d "$1" ]]; then
        cd "$1" || return 1
        return 0
    fi
    return 1
}

clean() {
    if [[ -f "$1" ]]; then
        rm "$1"
    elif [[ -d "$1" ]]; then
        if (($# >= 2)); then
            if ls "${1:?}"/"$2" 1>/dev/null 2>&1; then
                rm "${1:?}"/"$2"
            fi
        else
            rm -rf "${1:?}"/*
        fi
    fi
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

install_to_target() {
    source=$1
    target=$2

    if [[ ! -d "$target" ]]; then
        mkdir -p "$target"
    fi

    shopt -s dotglob

    echo "复制配置到 $target"
    for f in "$source"/*; do
        [[ -e "$f" ]] || break

        name=${f##*/}
        if [[ -e "$target/$name" ]]; then
            backup="$target/${name}_bak_$(date "+%Y-%m-%d-%H-%M-%S")"
            echo "备份已有的 $target/$name" 到 "$backup"
            mv "$target/$name" "$backup"
        fi
        cp -r "$f" "$target"
    done
}

json_format() {
    path=$1

    temp_path=${path}.bak
    jq --indent 4 . "$path" > "$temp_path"
    mv "$temp_path" "$path"
}

launch() {
    app_path=$1
    hide=$2

    window_style=""
    if [[ -n $hide && $hide != "false" ]]; then
        if [[ $hide == "true" ]]; then
            window_style="-WindowStyle Hidden"
        else
            window_style="-WindowStyle $hide"
        fi
    fi

    dir=$(dirname "$app_path")
    if (($# <= 2)); then
        powershell -Command Start-Process "\"$app_path\"" -WorkingDirectory "\"$dir\"" "$window_style"
    else
        powershell -Command Start-Process "\"$app_path\"" -ArgumentList "\"${*:3}\"" -WorkingDirectory "\"$dir\"" "$window_style"
    fi
}
