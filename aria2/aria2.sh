aria2_dir=$(dirname "$(readlink -f "$0")")
tracker="$aria2_dir/tracker.sh"
config="$aria2_dir/aria2.conf"
exe="$aria2_dir/aria2c.exe"

bash "$tracker"
powershell Start-Process "$exe" -ArgumentList "--conf-path=$config" -WindowStyle hidden
