# Zsh

## 仓库

- [https://github.com/zsh-users/zsh](https://github.com/zsh-users/zsh)
- [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [https://github.com/zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [https://github.com/msys2/msys2-installer](https://github.com/msys2/msys2-installer)

## 配置文件

| 文件          | 路径             | 说明          |
| ------------- | ---------------- | ------------- |
| .bash_profile | `C:/Users/User/` | Bash 配置文件 |
| .zshrc        | `C:/Users/User/` | Zsh 配置文件  |

## 注意

可配合 `MSYS2` 中的 `Zsh` 包部署在 `Windows` 端
- `Windows`端部署
    1. 下载并安装 `MSYS2`
    2. 修改 `User` 目录为 `Windows` 下的 `User` 目录
        1. 找到 `msys64/etc/nsswitch.conf`
        2. 修改 `db_home: cygwin desc` 为 `db_home: windows`
    3. 安装 `Zsh`：`pacman -S zsh`
- `Conda` 在 `Zsh` 中存在一些问题，建议使用 `PowerShell` 运行 `Conda` 相关命令
    - `MSYS2` 的 `Zsh` 不能进行 `Conda` 下的环境切换，请参考 [Conda in Windows under MSYS2 and Zsh line ending problems](https://github.com/conda/conda/issues/9922)
        - 若 `Zsh` 主题中存在符号字符，可能会导致切换环境时 conda 无法 decode，需要设置 `conda config --set changeps1 False`
