DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR="$DIR/config"

if ((is_windows)); then
    scoop install aria2
    scoop config aria2-warning-enabled false

    scoop install jq
fi

target="$HOME/.config/aria2"
install_to_target "$CONFIG_DIR" "$target"
echo "新建 $target/aria2.session"
touch "$target/aria2.session"

download_github_latest "mayswind" "AriaNg" "AllInOne" "$CONFIG_DIR/AriaNg.zip"
mkdir "$CONFIG_DIR/AriaNg"
unzip "$CONFIG_DIR/AriaNg.zip" -d "$CONFIG_DIR/AriaNg"
mv -f "$CONFIG_DIR/AriaNg" "$target"
rm "$CONFIG_DIR/AriaNg.zip"
