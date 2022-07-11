import os

from zhconv import convert

"""
简体转换成繁体
"""

# 字幕的路径
path = r''
# 输出路径
output_dir = r''


def ass_simplified_to_traditional():
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
        ext = ext[1:].lower()
        if ext == 'ass':
            ass = os.path.join(path, file)
            output_ass = os.path.join(output_dir, file)
            if os.path.exists(output_ass):
                os.remove(output_ass)

            with open(ass, 'r', encoding='utf-8') as f1, open(
                output_ass, 'a', encoding='utf-8'
            ) as f2:
                line = f1.readline()
                while line:
                    if line.startswith('Dialogue:'):
                        f2.write(convert(line, 'zh-hant'))
                    else:
                        f2.write(line)
                    line = f1.readline()
                print(name + '.ass已转化')


if __name__ == '__main__':
    ass_simplified_to_traditional()
