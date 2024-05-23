DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

target="$PORTABLE_DIR/Yazi"
download_github_latest "sxyazi" "yazi" "x86_64-pc-windows-msvc.zip" "$DIR/yazi.zip"
clean_target "$target"
unzip "$DIR/yazi.zip" -d "$DIR"
mv "$DIR/yazi-x86_64-pc-windows-msvc" "$DIR/Yazi"
mv "$DIR/Yazi" "$target"
rm "$DIR/yazi.zip"

download_github_latest "ouch-org" "ouch" "x86_64-pc-windows-msvc.zip" "$DIR/ouch.zip"
unzip "$DIR/ouch.zip" -d "$DIR"
mv "$DIR/ouch-x86_64-pc-windows-msvc" "$DIR/Ouch"
cp "$DIR/Ouch/ouch.exe" "$target"
rm -rf "$DIR/Ouch"
rm "$DIR/ouch.zip"

target="$APPDATA/yazi"
clean_target "$target"
install_to_target "$DIR" "$target"
