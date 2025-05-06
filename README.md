# config

本项目保存了我平时使用的一些程序的配置文件

## 说明

- 需要安装 `git`、`msys2`、`scoop`、`winget` 等必要环境来运行 `install.sh` 安装程序并恢复设置
    - 安装方法
        - 通过 `powershell` 运行 `install.ps1` 来安装必要环境
        - 或者手动安装必要环境
            - 推荐优先使用 `scoop` 安装，因为 `scoop` 将所有安装的程序统一存放在相同的路径
            - 对于比较复杂的程序，若 `scoop` 安装后不能正常运行，则可以改用 `winget` 安装，其等价于直接运行安装程序
            - 若 `winget` 和 `scoop` 都缺少某程序，则手动从 `github` 等发布网站下载
    - `install.sh` 会调用每个文件夹中的 `install.sh` 来安装对应程序并恢复设置
        - 可单独执行对应文件夹中的 `install.sh` 来安装对应的程序
