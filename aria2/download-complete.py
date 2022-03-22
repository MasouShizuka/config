import sys
import subprocess
from winotify import Notification, audio

app_id = 'Aria2'
title = '下载完成'
icon = 'D:/Tools/aria2/AriaNg.ico'

if __name__ == '__main__':
    msg = ''
    if len(sys.argv) >= 4:
        msg = sys.argv[3]

        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags = (
            subprocess.CREATE_NEW_CONSOLE | subprocess.STARTF_USESHOWWINDOW
        )
        startupinfo.wShowWindow = subprocess.SW_HIDE
        p = subprocess.Popen(
            ['bash', 'clean.sh', *(sys.argv[1:])], startupinfo=startupinfo
        )

    toast = Notification(app_id=app_id, title=title, msg=msg, icon=icon)
    toast.set_audio(audio.Default, loop=False)
    toast.show()
