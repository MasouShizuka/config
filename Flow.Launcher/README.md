# Flow.Launcher

## 仓库

- [https://github.com/Flow-Launcher/Flow.Launcher](https://github.com/Flow-Launcher/Flow.Launcher)
- [https://github.com/Chaoses-Ib/IbEverythingExt](https://github.com/Chaoses-Ib/IbEverythingExt)
- [https://github.com/stax76/run-hidden](https://github.com/stax76/run-hidden)

## 配置文件

| 文件          | 路径                 | 说明     |
| ------------- | -------------------- | -------- |
| Themes        | `$APPDATA/`          | 配色主题 |
| Plugins       | `$APPDATA/Settings/` | 插件配置 |
| Settings.json | `$APPDATA/Settings/` | 配置文件 |

## 注意

若需要设置文件管理器为终端，例如：`WezTerm`，以及终端下的程序，例如：`Yazi`
- 若`文件管理器路径`设置为终端，则在终端启动期间会有一个 popup window
- 若`文件管理器路径`设置为 `powershell` 或 `pwsh`，并利用参数 `-WindowStyle Hidden`，则只会在开始一小段时间会显示 popup window
- 若想完全隐藏 popup windows，则在 `powershell` 或 `pwsh` 的基础上，用 `run-hidden` 调用 `powershell` 或 `pwsh` 执行
