import os
import re
from subprocess import Popen

"""
用于批量压制相同格式的视频
对于视频、音频、字幕等部分，各部分需要位于相同目录下
以文件的序号为依据压制，相同序号的各个文件视作同一视频的各个部分，默认格式为：file 01.xxx
cmd 为一个文件按照格式放入 MKVToolNix 设置好压制文件与参数后的命令行（Linux/Unix shell 格式）
"""

# 输出目录，留空则默认为视频目录下的 output 文件夹
output_dir = r''
# 文件命名格式，主要提取序号
rule_file_format = re.compile(r"^.*?\s(\d+)\.?.*$")
# mkvmerge 的命令行，Linux/Unix shell 格式
cmd = ""


def read_from_cmd(cmd):
    # 命令行中各 path 替换成 {}
    cmd_format = cmd

    # 取得命令行中输出部分
    output = re.search(r"--output '([^']*)'", cmd_format)
    if output:
        output = output.group(1)

        cmd_format = cmd_format.replace(output, '{}')

    # 取得命令行中各个文件的部分
    files = []
    files_dir = []
    result = re.findall(r"'([^']*)'", cmd_format)
    for i in result:
        if os.path.exists(i):
            files.append(i)
            directory = os.path.split(i)[0]
            files_dir.append(directory)

            cmd_format = cmd_format.replace(i, '{}')

    return files_dir, cmd_format


def create_format_dict(files_dir):
    # 格式：'01': [file1_path, file2_path, ...]
    format_dict = {}
    for i in files_dir:
        for k in os.listdir(i):
            path = os.path.join(i, k).replace('\\', '/')
            if os.path.isfile(path):
                result = rule_file_format.match(k)
                if result:
                    num = result.group(1)
                else:
                    continue

                if not format_dict.__contains__(num):
                    format_dict[num] = []
                format_dict[num].append(path)

    return format_dict


def run_mkvmerge(cmd_format, format_dict, files_dir):
    for num, format_list in format_dict.items():
        video_path = format_list[0]
        directory, file_name = os.path.split(video_path)

        # 若 format_list 中的文件个数与 cmd 中的不同，则跳过
        if len(format_list) != len(files_dir):
            file_name = os.path.splitext(file_name)[0]
            print(f'{file_name} 相关文件缺失')
            continue

        # 输出目录若留空或与视频目录相同，则默认为视频目录下的 output 文件夹
        if output_dir == '' or output_dir == directory:
            output_path = os.path.join(directory, 'output', file_name).replace(
                '\\', '/'
            )
        else:
            output_path = os.path.join(output_dir, file_name).replace('\\', '/')

        # 调用 powershell 执行 cmd
        cmd_formatted = cmd_format.format(output_path, *format_list)
        p = Popen(['powershell', cmd_formatted])
        p.wait()


def main():
    files_dir, cmd_format = read_from_cmd(cmd)
    format_dict = create_format_dict(files_dir)
    run_mkvmerge(cmd_format, format_dict, files_dir)


if __name__ == '__main__':
    main()
