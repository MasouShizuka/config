# komorebi

## 仓库

- [https://github.com/LGUG2Z/komorebi](https://github.com/LGUG2Z/komorebi)
- [https://github.com/amnweb/yasb](https://github.com/amnweb/yasb)

## 配置文件

| 文件               | 路径                  | 说明                             |
| ------------------ | --------------------- | -------------------------------- |
| komorebi           |                       | komorebi 经过了**修改**的源码    |
| komorebi.json      |                       | komorebi 配置文件                |
| komorebi.bar*.json |                       | komorebi-bar 配置文件            |
| komorebi.ahk       |                       | komorebi 快捷键配置文件          |
| applications.yaml  |                       | komorebi 窗口配置文件            |
| yasb               |                       | YASB Reborn 经过了**修改**的源码 |
| config.yaml        | `$HOME/.config/yasb/` | YASB Reborn 配置文件             |
| styles.css         | `$HOME/.config/yasb/` | YASB Reborn 样式                 |

## 注意

- 需要将 `komorebi.exe`、`komorebic.exe`、`yasb.exe` 所在目录添加到 `系统Path` 环境变量
    - `komorebi` 项目可用命令 `cargo build --release` 生成 `komorebi.exe` 和 `komorebic.exe`
    - `yasb` 项目可用以下方式生成 `yasb.exe`：
        - `pyinstaller`
            - `pyinstaller --onefile --name yasb --hidden-import core.widgets.yasb.custom --hidden-import core.widgets.komorebi.workspaces --hidden-import core.widgets.komorebi.active_layout --hidden-import core.widgets.yasb.media --hidden-import core.widgets.komorebi.multi_window --hidden-import core.widgets.yasb.language --hidden-import core.widgets.yasb.wifi --hidden-import core.widgets.yasb.traffic --hidden-import core.widgets.yasb.cpu --hidden-import core.widgets.yasb.memory --hidden-import core.widgets.yasb.volume --hidden-import core.widgets.yasb.battery --hidden-import core.widgets.yasb.clock --noconsole --icon src/assets/images/app_icon.ico src/main.py`
