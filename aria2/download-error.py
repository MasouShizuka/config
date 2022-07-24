import sys

from winotify import Notification, audio

app_id = 'Aria2'
title = '下载失败'
icon = 'D:/Tools/aria2/AriaNg.ico'

if __name__ == '__main__':
    msg = ''
    if len(sys.argv) >= 4:
        msg = sys.argv[3]

    toast = Notification(app_id=app_id, title=title, msg=msg, icon=icon)
    toast.set_audio(audio.Default, loop=False)
    toast.show()
