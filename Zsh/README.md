# Zsh

## 仓库

- [https://github.com/zsh-users/zsh](https://github.com/zsh-users/zsh)
- [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [https://github.com/zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

## 配置文件

| 文件   | 路径            | 说明         |
| ------ | --------------- | ------------ |
| .zshrc | `C:/Users/User` | Zsh 配置文件 |

## 注意

可配合 `Git Bash` 和 `MSYS2` 中的 `Zsh` 包部署在 `Windows` 端
- `Windows`端部署请参考 [install-zsh-windows-git-bash.md](https://gist.github.com/fworks/af4c896c9de47d827d4caa6fd7154b6b)
- `MSYS2` 与 `Windows Terminal` 存在一定 BUG，即启用 `zsh-syntax-highlighting` 后，渲染高亮字符时光标会抖动，但仅限显示，不影响使用，请参考 [Cursor shaking in oh-my-zsh](https://github.com/microsoft/terminal/issues/8661)
- `MSYS2` 的 `Zsh` 不能进行 `Conda` 下的环境切换，请参考 [Conda in Windows under MSYS2 and Zsh line ending problems](https://github.com/conda/conda/issues/9922)
    - 妥协手段：令 `Zsh` 存在于 `Powershell` 中，即让 `Powershell` 启动时执行 `Zsh`，若要进行 `Conda` 环境切换，则使用 `exit` 退出 `Zsh`，在 `Powershell` 中完成后，再进入 `Zsh`
