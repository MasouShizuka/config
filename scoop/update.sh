CONFIG_DIR=$(dirname "$(readlink -f "$0")")/config

powershell -File "$HOME/scoop/apps/scoop/current/bin/checkver.ps1" "-App" "*" "-Dir" "$CONFIG_DIR/workspace" "-u"
