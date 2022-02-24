aria2_dir="D:/Tools/Aria2"
config="$aria2_dir/aria2.conf"
config_backup="$aria2_dir/aria2_backup.conf"
exe="$aria2_dir/aria2c.exe"

trackers_file="best_aria2.txt"
url="https://trackerslist.com/$trackers_file"

if curl -O $url; then
    echo "trackers downloaded successfully"

    if [[ -f $config ]]; then
        rm $config
    fi
    while read -r line; do
        if [[ ${line:0:11} = "bt-tracker=" ]]; then
            echo "bt-tracker=$(cat $aria2_dir/$trackers_file)" >>$config
        else
            echo "$line" >>$config
        fi
    done <$config_backup

    rm $aria2_dir/$trackers_file
else
    echo "trackers download failed"
fi

nohup $exe --conf-path=$config >/dev/null 2>&1 &
