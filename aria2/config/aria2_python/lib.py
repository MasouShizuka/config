from os.path import abspath, dirname, join
from subprocess import Popen
from sys import argv, exit

from winotify import Notification, audio


def parse_aria2_args():
    args = argv

    num_args = len(args)
    if num_args < 4:
        print(f"Not enough arguments, less than 4: {num_args}.")
        exit(1)

    return args


def execute_script(script_name, args):
    current_dir = dirname(abspath(args[0]))
    script_path = join(current_dir, script_name)

    Popen(
        ["sh", script_path, *(args[1:])],
        shell=True,
    )


def toast(title, args):
    current_dir = dirname(abspath(args[0]))
    icon_path = join(current_dir, "AriaNg.ico")

    toast = Notification(app_id="Aria2", title=title, msg=args[3], icon=icon_path)
    toast.set_audio(audio.Default, loop=False)
    toast.show()
