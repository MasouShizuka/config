DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

target="/d/Tools/Yazi"
download_github_latest "sxyazi" "yazi" "x86_64-pc-windows-msvc.zip" "$DIR/yazi.zip"
clean_target "$target/Yazi"
unzip "$DIR/yazi.zip" -d "$DIR"
mv "$DIR/yazi-x86_64-pc-windows-msvc" "$DIR/Yazi"
mv "$DIR/Yazi" "$target"
rm "$DIR/yazi.zip"

target="$APPDATA/yazi"
clean_target "$target"
install_to_target "$DIR" "$target"
