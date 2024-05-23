# Yazi

## 仓库

- [https://github.com/sxyazi/yazi](https://github.com/sxyazi/yazi)

## 配置文件

| 文件   | 路径             | 说明          |
| ------ | ---------------- | ------------- |
| config | `$APPDATA/yazi/` | Yazi 配置文件 |

## 注意

- `Yazi` 目前无法通过 `winget` 安装，需要从 `github` 下载
    - 通过 `install.sh` 安装，请提前指定 `lib.sh` 中的 `PORTABLE_DIR`
    - 请手动将该程序的安装目录添加到系统变量的 `Path`
- `Yazi` 需要配合一些程序使用：
    - 文件类型检测：
        - `file`：该文件在 `msys2` 下自带，或者安装 `git` 并设置环境变量 `YAZI_FILE_ONE=C:\Program Files\Git\usr\bin\file.exe`
    - 搜索：
        - `fd`
        - `fzf`
        - `ripgrep`
    - 预览：
        - `jq`
        - `ouch`
