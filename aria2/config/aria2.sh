aria2_dir=$(dirname "$(readlink -f "$0")")
tracker="$aria2_dir/tracker.sh"
config="$aria2_dir/aria2.conf"

bash "$tracker"
powershell -Command Start-Process "aria2c" -ArgumentList "--conf-path=$config" -WindowStyle Hidden
