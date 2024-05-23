DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

winget install voidtools.Everything --version 1.4.1.1023 --source winget --accept-source-agreements
winget pin add --id voidtools.Everything

curl -kL -o "$DIR/IbEverythingExt.zip" "https://github.com/Chaoses-Ib/IbEverythingExt/releases/download/v0.6-alpha.5/IbEverythingExt.v0.6-alpha.5.zip"
unzip "$DIR/IbEverythingExt.zip"
mv "$DIR/Everything"/* "$PROGRAMFILES/Everything"
rmdir "$DIR/Everything"
rm "$DIR/IbEverythingExt.zip"

winget install Flow-Launcher.Flow-Launcher --accept-source-agreements
target="$APPDATA/FlowLauncher"
clean_target "$target"
install_to_target "$DIR" "$target"
