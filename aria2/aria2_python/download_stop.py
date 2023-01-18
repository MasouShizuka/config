from lib import *

if __name__ == "__main__":
    args = parse_aria2_args()
    execute_script("delete.sh", args)
    toast("下载停止", args)
