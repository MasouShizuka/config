DIR=$(dirname "$(readlink -f "$0")")

nohup pythonw "$DIR"/yasb/src/main.py >/dev/null 2>&1 &
