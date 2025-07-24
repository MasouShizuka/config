# config

本项目保存了我平时使用的一些程序的配置文件

## 说明

- 需要 `git`、`msys2`、`scoop`、`winget` 等必要环境来运行 `install.sh` 安装程序并恢复设置
    - 安装方法
        - 通过 `powershell` 运行 `windows_install.ps1` 来安装必要环境
        - 或者手动安装必要环境
            - 推荐优先使用 `scoop` 安装，因为 `scoop` 将所有安装的程序统一存放在相同的路径
            - 对于比较复杂的程序，若 `scoop` 安装后不能正常运行，则可以改用 `winget` 安装，其等价于直接运行安装程序
            - 若 `winget` 和 `scoop` 都缺少某程序，则手动从 `github` 等发布网站下载
    - `install.sh` 会调用每个文件夹中的 `install.sh` 来安装对应程序并恢复设置
        - 可单独执行对应文件夹中的 `install.sh` 来安装对应的程序

## 安装指南

### Windows 安装指南

1. 控制面板->安全和维护->更改用户账户控制设置->选择从不通知
2. 参照 [netnr/kms](https://github.com/netnr/kms) 激活 Windows11
3. 参照 [Raphire/Win11Debloat](https://github.com/Raphire/Win11Debloat) 去除多余组件
4. `Windows Powershell` 执行：`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
5. 执行 `windows_install.ps1`
    - 可能需要：右键->属性->勾选解除锁定
6. 通过各个程序的 `install.sh` 来安装对应的程序
