# komorebi

## 仓库

- [https://github.com/LGUG2Z/komorebi](https://github.com/LGUG2Z/komorebi)
- [https://github.com/denBot/yasb](https://github.com/denBot/yasb)

## 配置文件

| 文件              | 路径                  | 说明                                        |
| ----------------- | --------------------- | ------------------------------------------- |
| komorebi          |                       | komorebi 源码，经过了**修改**               |
| komorebi.json     |                       | komorebi 配置文件                           |
| komorebi.ahk      |                       | komorebi 快捷键配置文件                     |
| applications.yaml |                       | komorebi 窗口配置文件                       |
| yasb              |                       | Yet Another Status Bar 源码，经过了**修改** |
| config.yaml       | `$HOME/.config/yasb/` | Yet Another Status Bar 配置文件             |
| styles.css        | `$HOME/.config/yasb/` | Yet Another Status Bar 样式                 |

## 注意

- 需要将 `komorebi.exe`、`komorebic.exe`、`yasb.exe` 所在目录添加到 `系统Path` 环境变量
    - `komorebi` 项目可用命令 `cargo build --release` 生成 `komorebi.exe` 和 `komorebic.exe`
    - `yasb` 项目可用以下方式生成 `yasb.exe`：
        - `pyinstaller`
            - `pyinstaller --onefile --name yasb --hidden-import core.widgets.komorebi.workspaces --hidden-import core.widgets.komorebi.active_layout --hidden-import core.widgets.komorebi.multi_window --hidden-import core.widgets.yasb.input_method --hidden-import core.widgets.yasb.wifi --hidden-import core.widgets.yasb.traffic --hidden-import core.widgets.yasb.cpu --hidden-import core.widgets.yasb.memory --hidden-import core.widgets.yasb.gpu --hidden-import core.widgets.yasb.battery --hidden-import core.widgets.yasb.clock --noconsole --icon img/yasb_icon.ico src/main.py`
        - `nuitka`
            - `python -m nuitka --onefile --include-module=core.widgets.komorebi.workspaces --include-module=core.widgets.komorebi.active_layout --include-module=core.widgets.komorebi.multi_window --include-module=core.widgets.yasb.input_method --include-module=core.widgets.yasb.wifi --include-module=core.widgets.yasb.traffic --include-module=core.widgets.yasb.cpu --include-module=core.widgets.yasb.memory --include-module=core.widgets.yasb.gpu --include-module=core.widgets.yasb.battery --include-module=core.widgets.yasb.clock --output-filename=yasb --remove-output --disable-console --windows-icon-from-ico=img/yasb_icon.ico --enable-plugin=pyqt6 src/main.py`
                - `onefile` 参数能够生成单文件执行文件，但是该单文件每次运行时会在 `TEMP` 解压临时文件夹并运行其中的程序，相当于生成的单文件是个压缩文件
            - `python -m nuitka --standalone --include-module=core.widgets.komorebi.workspaces --include-module=core.widgets.komorebi.active_layout --include-module=core.widgets.komorebi.multi_window --include-module=core.widgets.yasb.input_method --include-module=core.widgets.yasb.wifi --include-module=core.widgets.yasb.traffic --include-module=core.widgets.yasb.cpu --include-module=core.widgets.yasb.memory --include-module=core.widgets.yasb.gpu --include-module=core.widgets.yasb.battery --include-module=core.widgets.yasb.clock --output-filename=yasb --remove-output --disable-console --windows-icon-from-ico=img/yasb_icon.ico --enable-plugin=pyqt6 src/main.py`
                - `standalone` 参数生成的文件夹与 `onefile` 生成的单文件运行时解压的文件夹相同
