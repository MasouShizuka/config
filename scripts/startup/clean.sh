DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
PARENT_DIR=$(dirname "$PARENT_DIR")
source "$PARENT_DIR/lib.sh"

# ╭──────────────╮
# │ MSYS2 的 tmp │
# ╰──────────────╯
if ((is_windows)); then
    clean "$HOME/scoop/apps/msys2/current/tmp"
fi

# ╭──────╮
# │ Temp │
# ╰──────╯
if ((is_windows)); then
    clean "$LOCALAPPDATA/Temp"
fi

# ╭──────────────────────────╮
# │ vscode 的 Service Worker │
# ╰──────────────────────────╯
if ((is_windows)); then
    clean "$HOME/scoop/persist/vscode/data/user-data/Service Worker/CacheStorage"
    clean "$HOME/scoop/persist/vscode/data/user-data/Service Worker/ScriptCache"
fi
