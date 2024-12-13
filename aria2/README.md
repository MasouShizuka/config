# aria2

## 仓库

- [https://github.com/aria2/aria2](https://github.com/aria2/aria2)
- [https://github.com/P3TERX/aria2.conf](https://github.com/P3TERX/aria2.conf)
- [https://github.com/XIU2/TrackersListCollection](https://github.com/XIU2/TrackersListCollection)

## 配置文件

| 文件                 | 路径                   | 说明                                                                                                                                                                                             |
| -------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| aria2_python         | `$HOME/.config/aria2/` | 生成 `on-download` 的可执行文件的 `python` 项目                                                                                                                                                  |
| aria2_rust           | `$HOME/.config/aria2/` | 生成 `on-download` 的可执行文件的 `rust` 项目                                                                                                                                                    |
| aria2.conf           | `$HOME/.config/aria2/` | 配置文件                                                                                                                                                                                         |
| aria2.sh             | `$HOME/.config/aria2/` | 启动脚本                                                                                                                                                                                         |
| script.conf          | `$HOME/.config/aria2/` | 附加功能脚本配置文件。                                                                                                                                                                           |
| core                 | `$HOME/.config/aria2/` | 附加功能脚本核心文件。所有脚本都依赖于此文件运行。                                                                                                                                               |
| clean.sh             | `$HOME/.config/aria2/` | 文件清理脚本。在下载完成后执行(`on-download-complete`)，自动清理控制文件(`*.aria2`)、种子文件(`*.torrent`)和空目录。（默认启用）                                                                 |
| delete.sh            | `$HOME/.config/aria2/` | 文件删除脚本。在下载停止后执行(`on-download-stop`)，当删除正在下载的任务后自动删除相关文件，并自动清理控制文件(`*.aria2`)、种子文件(`*.torrent`)和空目录，防止不必要的磁盘空间占用。（默认启用） |
| tracker.sh           | `$HOME/.config/aria2/` | BT tracker 列表更新脚本。在 aria2 配置文件(aria2.conf)所在目录执行即可获取最新 tracker 列表并添加到配置文件中。                                                                                  |
| dht.dat</br>dht6.dat | `$HOME/.config/aria2/` | DHT 网络节点数据文件。提升 BT 下载率和下载速度的关键之一。                                                                                                                                       |
| AriaNg.ico           | `$HOME/.config/aria2/` | 图标                                                                                                                                                                                             |

## 说明

- `aria2_python` 项目可用命令 `pyinstaller -Fw -i AriaNg.ico xxx.py` 生成 `aria2.conf` 中对应的 `exe` 文件
- `aria2_rust` 项目可用命令 `cargo build --release` 生成 `aria2.conf` 中对应的 `exe` 文件
- 脚本中用到了 `jq` 命令，因此需要安装 `jq`，选择以下任何一种方式：
    - `scoop install jq`
    - `winget install jqlang.jq --accept-source-agreements`
    - `pacman -S mingw-w64-ucrt-x86_64-jq`
