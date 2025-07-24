# WSL

## 仓库

- [https://github.com/microsoft/WSL](https://github.com/microsoft/WSL)

## 配置文件

| 文件       | 路径     | 说明         |
| ---------- | -------- | ------------ |
| .wslconfig | `$HOME/` | WSL 配置文件 |

## 安装

### Arch Linux

1. 安装镜像
    - `wsl --install archlinux`
2. 更新
    - `pacman -Syu`
3. 设置 Root 密码
    - `passwd`
4. 设置 locale
    - `locale-gen`
    - 取消 `/etc/locale.gen` 的注释：`en_US.UTF-8 UTF-8`
    - `locale-gen`
5. 设置默认用户
    - 安装 `sudo`
        - `pacman -S sudo`
        - 取消 `/etc/sudoers` 的注释：`%wheel ALL=(ALL:ALL) NOPASSWD: ALL`
    - 添加用户并设置密码
        ```bash
        useradd -m -G wheel username
        passwd username
        ```
    - 设置添加用户为默认用户
        - 添加以下内容到 `/etc/wsl.conf`
            ```conf
            [user]
            default=username
            ```
    - 终止当前 session 并重新进入
        - `wsl --terminate archlinux`
6. 链接 bash 配置到本机
    ```bash
    userprofile=$(wslpath "$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')")
    rm $HOME/.bashrc
    ln -s "$userprofile/.bashrc" "$HOME/.bashrc"
    ```
