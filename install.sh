DIR=$(dirname "$(readlink -f "$0")")
source "$DIR/lib.sh"

execute_scripts_of_subdirectories "$DIR" "install.sh" "安装"
