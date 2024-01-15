DIR=$(dirname "$(readlink -f "$0")")

for d in "$DIR"/*; do
    [[ -e "$d" ]] || break

    if [[ -d $d ]]; then
        install="$d/install.sh"
        if [[ -f $install ]]; then
            name=${d##*/}
            echo "$name 开始安装"
            bash "$install"
            echo "$name 安装完成"
            echo "----------------------------------------"
        fi
    fi
done
