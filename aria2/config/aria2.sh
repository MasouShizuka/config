aria2_dir=$(dirname "$(readlink -f "$0")")
tracker="$aria2_dir/tracker.sh"
config=$(cygpath -m "$aria2_dir/aria2.conf")

sh "$tracker"
powershell -Command Start-Process "aria2c" -ArgumentList "--conf-path=\"$config\"" -WorkingDirectory "\"$aria2_dir\"" -WindowStyle Hidden
