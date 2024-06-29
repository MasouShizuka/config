DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install aria2 --no-cache
scoop config aria2-warning-enabled false
target="$HOME/.config/aria2"
clean_target "$target"
install_to_target "$CONFIG_DIR" "$target"
echo "新建 $target/aria2.session"
touch "$target/aria2.session"

download_github_latest "mayswind" "AriaNg" "AllInOne" "$CONFIG_DIR/AriaNg.zip"
clean_target "$target/AriaNg"
mkdir "$CONFIG_DIR/AriaNg"
unzip "$CONFIG_DIR/AriaNg.zip" -d "$CONFIG_DIR/AriaNg"
mv "$CONFIG_DIR/AriaNg" "$target"
rm "$CONFIG_DIR/AriaNg.zip"
