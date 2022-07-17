import os
import re
from datetime import datetime

from moviepy.editor import VideoFileClip

"""
用于去除字幕中结束时间大于视频总长
原因是由于部分播放器对于字幕中存在结束时间大于视频总长的视频，会将字幕中的最大时间作为视频长度
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
    clip = VideoFileClip(file_path)
    return clip.duration


def ass_cut_part_exceed_video():
    if not os.path.exists(path):
        print('目录不存在')
        return 0

    global output_dir
    if output_dir == '' or output_dir == path:
        output_dir = os.path.join(path, 'output')
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)

    files = os.listdir(path)
    for file in files:
        name, ext = os.path.splitext(file)
        ext = ext.lower()[1:]
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

                    rule = re.compile(r'^Dialogue\:.+?\,.+?\,(\d+\:\d+\:\d+\.\d+)\,.+$')
                    with open(danmaku, 'r', encoding='utf-8') as f1, open(
                        output_ass, 'a', encoding='utf-8'
                    ) as f2:
                        line = f1.readline()
                        while line:
                            info = rule.match(line.rstrip())
                            if info:
                                try:
                                    end = datetime.strptime(
                                        info.group(1),
                                        '%H:%M:%S.%f',
                                    )
                                except:
                                    pass
                                if end < length:
                                    f2.write(line)
                            else:
                                f2.write(line)
                            line = f1.readline()
                        print(name + '.ass 已转化')
                except:
                    pass


if __name__ == '__main__':
    ass_cut_part_exceed_video()
