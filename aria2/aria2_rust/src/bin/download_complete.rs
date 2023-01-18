use aria2_rust::*;

fn main() {
    let args: Vec<String> = parse_aria2_args();
    execute_script("clean.sh", &args);
    toast("Aria2 下载完成", &args);
}
