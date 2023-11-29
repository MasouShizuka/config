# KeyMouse

## 仓库

- [https://github.com/iscooool/KeyMouse](https://github.com/iscooool/KeyMouse)

## 配置文件

| 文件        | 路径        | 说明                          |
| ----------- | ----------- | ----------------------------- |
| KeyMouse    |             | KeyMouse 源码，经过了**修改** |
| config.json | `KeyMouse/` | KeyMouse 配置文件             |

## 注意

- `config.json` 需要配合修改后的源码编译出的 `KeyMouse.exe`：
    1. 运行命令 `git clone --recurse-submodules https://github.com/iscooool/KeyMouse.git`
    2. 将修改后的源码覆盖对应的文件
    3. 安装 `Visual Studio`，导入项目，编译生成 `KeyMouse.exe`
        1. 下载 `Visual Studio Installer`，安装最新的 `Visual Studio`
            - `工作负载` 中选择 `使用 C++ 的桌面开发`
            - `单个组件` 中选择 `适用于最新 vxxx 生成工具的 C++ ATL (x86 & x64)`、`适用于最新 vxxx 生成工具的 C++ MFC (x86 & x64)`
        2. `解决方案`：`Release`、`x64`
        3. `配置属性`->`高级`->`MFC 的使用`：`在静态库中使用 MFC`
            - 若编译时出现 `LNK2001` 错误，则在 `配置属性`->`链接器`->`输入`->`附加依赖项` 中添加 `gdi32.lib`
        4. `配置属性`->`C/C++`->`代码生成`->`运行库`：`多线程 (/MT)`
        5. `重新生成`
