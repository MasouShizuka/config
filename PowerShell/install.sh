DIR=$(dirname "$(readlink -f "$0")")
PARENT_DIR=$(dirname "$DIR")
source "$PARENT_DIR/lib.sh"
CONFIG_DIR=$DIR/config

scoop install pwsh

target="$HOME/scoop/persist/pwsh/Microsoft.PowerShell_profile.ps1"
cat "$CONFIG_DIR/Microsoft.PowerShell_profile.ps1" > "$target"
