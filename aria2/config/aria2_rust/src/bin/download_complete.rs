use aria2_rust::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = parse_aria2_args();
    toast("Aria2 下载完成", &args)?;
    execute_script("clean.sh", &args)?;

    Ok(())
}
