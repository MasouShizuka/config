DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install aria2 --no-cache
scoop config aria2-warning-enabled false
target="$HOME/.config/aria2"
clean_target "$target"
install_to_target "$DIR" "$target"
echo "新建 $target/aria2.session"
touch "$target/aria2.session"

download_github_latest "mayswind" "AriaNg" "AllInOne" "$DIR/AriaNg.zip"
clean_target "$target/AriaNg"
mkdir "$DIR/AriaNg"
unzip "$DIR/AriaNg.zip" -d "$DIR/AriaNg"
mv "$DIR/AriaNg" "$target"
rm "$DIR/AriaNg.zip"
