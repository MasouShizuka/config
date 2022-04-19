aria2_dir=$(dirname "$(readlink -f "$1")")
tracker="$aria2_dir/tracker.sh"
config="$aria2_dir/aria2.conf"
exe="$aria2_dir/aria2c.exe"

$tracker
"$exe" --conf-path="$config" >/dev/null 2>&1 &
