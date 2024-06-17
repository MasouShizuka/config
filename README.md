# config

本项目保存了我平时使用的一些程序的配置文件

## 说明

- `sh` 文件可通过安装 `msys2` 来运行
    - 将 `msys64/ucrt64/bin` 和 `msys64/usr/bin` 添加到环境变量的系统变量的 `Path`，之后可用 `bash` 命令运行 `sh` 文件
    - 可将 `msys64/usr/bin/bash.exe` 设置为 `sh` 文件的默认打开方式，之后可双击运行 `sh` 脚本
- `install.sh` 会调用每个文件夹中的 `install.sh` 来安装所有可安装的程序
    - 需要提前安装 `scoop`、`winget`、`msys2`、`git`、`unzip` 等程序
        - 推荐优先使用 `scoop` 安装，因为 `scoop` 将所有安装的程序统一存放在相同的路径
        - 对于比较复杂的程序，若 `scoop` 安装后不能正常运行，则可以改用 `winget` 安装，其等价于直接运行安装程序
        - 若 `winget` 和 `scoop` 都缺少某程序，则手动从 `github` 等发布网站下载
            - 对于手动下载的命令行程序，需要将该程序的安装目录手动添加到系统变量的 `Path`
            - 对于 `install.sh` 中的手动安装方式，请提前指定 `lib.sh` 中的 `PORTABLE_DIR` 作为安装路径
    - 可单独执行对应文件夹中的 `install.sh` 来安装对应的程序
