from lib import *

if __name__ == "__main__":
    args = parse_aria2_args()
    execute_script("clean.sh", args)
    toast("下载完成", args)