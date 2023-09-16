# komorebi

## 仓库

- [https://github.com/LGUG2Z/komorebi](https://github.com/LGUG2Z/komorebi)
- [https://github.com/denBot/yasb](https://github.com/denBot/yasb)

## 配置文件

| 文件            | 路径                  | 说明                                             |
| --------------- | --------------------- | ------------------------------------------------ |
| yasb            | `komorebi/`           | Yet Another Status Bar 源码                      |
| config.yaml     | `$HOME/.config/yasb/` | Yet Another Status Bar 配置文件                  |
| styles.css      | `$HOME/.config/yasb/` | Yet Another Status Bar 样式                      |
| komorebi_v1.ahk |                       | komorebi 配置文件<br>可配合 MyKeymap 1 版本 使用 |
| komorebi_v2.ahk |                       | komorebi 配置文件<br>可配合 MyKeymap 2 版本 使用 |

## 注意

- 需要将 `komorebi路径` 添加到 `系统Path` 环境变量
- `yasb` 项目可用命令 `pyinstaller main.spec` 生成 `yasb.exe`
    - `yasb` 的配置文件 `config.yaml` 和 `styles.css` 可位于 `yasb.exe` 同目录或 `$HOME/.config/yasb`
