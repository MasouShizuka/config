DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install everything@1.4.1.1023 --no-cache
scoop hold everything

curl -kL -o "$DIR/IbEverythingExt.zip" "https://github.com/Chaoses-Ib/IbEverythingExt/releases/download/v0.6-alpha.5/IbEverythingExt.v0.6-alpha.5.zip"
unzip "$DIR/IbEverythingExt.zip"
mv "$DIR/Everything"/* "$HOME/scoop/apps/everything/current"
rmdir "$DIR/Everything"
rm "$DIR/IbEverythingExt.zip"

scoop install flow-launcher --no-cache
target="$APPDATA/FlowLauncher"
clean_target "$target"
install_to_target "$DIR" "$target"
