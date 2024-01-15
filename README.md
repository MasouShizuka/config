# config

本项目保存了我平时使用的一些程序的配置文件

## 说明

- `sh` 文件可通过安装 `msys2` 来运行
    - 将 `msys64/ucrt64/bin` 和 `msys64/usr/bin` 添加到环境变量的系统变量的 `Path`，之后可用 `bash` 命令运行 `sh` 文件
    - 可将 `msys64/usr/bin/bash.exe` 设置为 `sh` 文件的默认打开方式，之后可双击运行 `sh` 脚本
- `install.sh` 会调用每个文件夹中的 `install.sh` 来安装所有可安装的程序
    - 需要提前安装 `msys2`、`git` 等程序
    - 可单独执行对应文件夹中的 `install.sh` 来对应的程序
