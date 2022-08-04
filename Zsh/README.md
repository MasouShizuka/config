# Zsh

## 仓库

- [https://github.com/zsh-users/zsh](https://github.com/zsh-users/zsh)
- [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [https://github.com/zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [https://github.com/msys2/msys2-installer](https://github.com/msys2/msys2-installer)

## 配置文件

| 文件   | 路径             | 说明         |
| ------ | ---------------- | ------------ |
| .zshrc | `C:/Users/User/` | Zsh 配置文件 |

## 注意

可配合 `MSYS2` 中的 `Zsh` 包部署在 `Windows` 端
- `Windows`端部署
    1. 下载并安装 `MSYS2`
    2. 修改 `User` 目录为 `Windows` 下的 `User` 目录
        1. 找到 `msys64\etc\nsswitch.conf`
        2. 修改 `db_home: cygwin desc` 为 `db_home: windows`
    3. 安装 `Zsh`：`pacman -S zsh`
- `MSYS2` 的 `Zsh` 不能进行 `Conda` 下的环境切换，请参考 [Conda in Windows under MSYS2 and Zsh line ending problems](https://github.com/conda/conda/issues/9922)
    - 妥协手段：令 `Zsh` 运行于 `Powershell` 中，即让 `Powershell` 启动时执行 `Zsh`，若要进行 `Conda` 环境切换，则使用 `exit` 退出 `Zsh`，在 `Powershell` 中完成后，再进入 `Zsh`
