DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

scoop install neovim --no-cache

'{ "version": "1.0", "url": "https://github.com/daipeihust/im-select/raw/master/win/out/x64/im-select.exe", "bin": "im-select.exe" }' > "$DIR/im-select.json"
scoop install "$DIR/im-select.json"
rm "$DIR/im-select.json"

target="$LOCALAPPDATA/nvim"
clean_target "$target"
install_to_target "$DIR" "$target"
