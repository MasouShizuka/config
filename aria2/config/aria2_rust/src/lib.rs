use std::collections::HashMap;
use std::env::{args, current_dir, vars};
use std::process::{exit, Command};
use winrt_notification::{Duration, IconCrop, Sound, Toast};

pub fn parse_aria2_args() -> Vec<String> {
    let args: Vec<String> = args().collect();

    let num_args = args.len();
    if num_args < 4 {
        println!("Not enough arguments, less than 4: {}.", num_args);
        exit(1);
    }

    args
}

pub fn execute_script(script_name: &str, args: &Vec<String>) {
    let current_dir = current_dir().unwrap();
    let script_path = current_dir.join(script_name);

    let filtered_env: HashMap<String, String> = vars().filter(|&(ref k, _)| k == "PATH").collect();

    let mut command = Command::new("sh");
    command
        .envs(&filtered_env)
        .current_dir(current_dir)
        .arg(script_path);
    for i in &args[1..] {
        command.arg(i);
    }

    command
        .output()
        .expect("Script can't be executed by aria2.");
}

pub fn toast(title: &str, args: &Vec<String>) {
    let current_dir = current_dir().unwrap();
    let icon_path = current_dir.join("AriaNg.ico");

    Toast::new(Toast::POWERSHELL_APP_ID)
        .icon(&icon_path, IconCrop::Circular, "Aria2")
        .title(title)
        .text1(&args[3])
        .sound(Some(Sound::Default))
        .duration(Duration::Short)
        .show()
        .expect("Unable to toast.");
}
