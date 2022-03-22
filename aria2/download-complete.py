import sys
from subprocess import Popen
from winotify import Notification, audio

app_id = 'Aria2'
title = '下载完成'
icon = 'D:/Tools/aria2/AriaNg.ico'

if __name__ == '__main__':
    if len(sys.argv) >= 4:
        Popen(['bash', 'clean.sh', *(sys.argv[1:])])

        toast = Notification(app_id=app_id, title=title, msg=sys.argv[3], icon=icon)
        toast.set_audio(audio.Default, loop=False)
        toast.show()
