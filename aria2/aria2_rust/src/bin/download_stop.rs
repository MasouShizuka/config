use aria2_rust::*;

fn main() {
    let args: Vec<String> = parse_aria2_args();
    toast("Aria2 下载停止", &args);
    execute_script("delete.sh", &args);
}
