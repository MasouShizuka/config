startup_script_dir=$(dirname "$(readlink -f "$1")")/startup

for f in "$startup_script_dir"/*.sh; do
    [[ -e "$f" ]] || break

    sh "$f"
done
