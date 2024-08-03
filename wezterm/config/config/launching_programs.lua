local M = {}

M.zsh = {
    label = "Zsh",
    args = {
        "ucrt64.cmd",
        "-shell",
        "zsh",
    },
}

M.powershell = {
    label = "Powershell",
    args = {
        "pwsh",
        "-NoLogo",
    },
}

M.arch = {
    label = "Arch",
    args = {
        "wsl",
        "-d",
        "Arch",
        "--cd",
        "~",
    },
}

M.options = {
    default_prog = M.zsh.args,

    launch_menu = {
        M.zsh,
        M.powershell,
        M.arch,
    },
}

return M
