import re
import os
from datetime import datetime
from cv2 import VideoCapture

"""
用于去除字幕中开始/结束时间大于视频总长
原因是由于部分播放器对于字幕中存在开始/结束时间大于视频总长的视频，会将字幕中的最大时间作为视频长度
因此会存在一部分大于视频实际长度的假进度条
"""

# 视频与字幕的路径
path = r''
# 输出路径
output_dir = r''


def get_time(sec):
    h = int(sec // 3600)
    sec %= 3600
    m = int(sec // 60)
    sec %= 60
    s = sec
    return '{}:{}:{:.2f}'.format(h, m, s)


def get_video_duration(file_path):
    cap = VideoCapture(file_path)
    if cap.isOpened():
        rate = cap.get(5)
        frame = cap.get(7)
        duration = frame / rate
        return duration
    return -1


def cut_sub_time_over_video():
    if not os.path.exists(path):
        print('目录不存在')
        return 0
    if output_dir == '' or output_dir == path:
        output_dir = os.path.join(path, 'output')
    elif not os.path.exists(output_dir):
        os.mkdir(output_dir)

    files = os.listdir(path)
    rule = re.compile(r'^Dialogue\:.+?\,.+?\,(\d+\:\d+\:\d+\.\d+)\,.+$')
    for file in files:
        name, ext = os.path.splitext(file)
        ext = ext.lower()
        if ext in ('mkv', 'mp4'):
            danmaku = os.path.join(path, name + '.ass')
            if os.path.exists(danmaku):
                try:
                    output_ass = os.path.join(output_dir, name + '.ass')
                    if os.path.exists(output_ass):
                        os.remove(output_ass)
                    length = datetime.strptime(
                        get_time(get_video_duration(os.path.join(path, file))),
                        '%H:%M:%S.%f',
                    )
                    with open(danmaku, 'r', encoding='utf-8') as f1, open(
                        output_ass, 'a', encoding='utf-8'
                    ) as f2:
                        line = f1.readline()
                        while line:
                            info = rule.match(line.rstrip())
                            if info:
                                try:
                                    end = datetime.strptime(
                                        info.group(1), '%H:%M:%S.%f'
                                    )
                                except:
                                    pass
                                if end < length:
                                    f2.write(line)
                            else:
                                f2.write(line)
                            line = f1.readline()
                        print(name + '.ass已转化')
                except:
                    pass


if __name__ == "__main__":
    cut_sub_time_over_video()
