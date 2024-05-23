# config

本项目保存了我平时使用的一些程序的配置文件

## 说明

- `sh` 文件可通过安装 `msys2` 来运行
    - 将 `msys64/ucrt64/bin` 和 `msys64/usr/bin` 添加到环境变量的系统变量的 `Path`，之后可用 `bash` 命令运行 `sh` 文件
    - 可将 `msys64/usr/bin/bash.exe` 设置为 `sh` 文件的默认打开方式，之后可双击运行 `sh` 脚本
- `install.sh` 会调用每个文件夹中的 `install.sh` 来安装所有可安装的程序
    - 需要提前安装 `msys2`、`git`、`unzip` 等程序
    - 可单独执行对应文件夹中的 `install.sh` 来对应的程序
    - 有些程序可能无法通过 `winget` 安装，需要从 `github` 等发布网站下载
        - 通过 `install.sh` 安装，请提前指定 `lib.sh` 中的 `PORTABLE_DIR` 作为安装路径
        - 对于需要从命令行调用的程序，请手动将该程序的安装目录添加到系统变量的 `Path`
