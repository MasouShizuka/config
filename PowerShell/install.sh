DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"

if ((!is_windows)); then
    echo "不是 Windows 平台"
    exit 1
fi

CONFIG_DIR="$DIR/config"

scoop install pwsh

target="$HOME/scoop/persist/pwsh/Microsoft.PowerShell_profile.ps1"
cat "$CONFIG_DIR/Microsoft.PowerShell_profile.ps1" > "$target"
