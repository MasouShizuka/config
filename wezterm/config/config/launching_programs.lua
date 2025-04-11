local M = {}

M.bash = {
    label = "Bash",
    args = {
        "ucrt64.cmd",
    },
}

M.powershell = {
    label = "Powershell",
    args = {
        "pwsh",
        "-NoLogo",
    },
}

M.wsl_arch = {
    label = "WSL:Arch",
    args = {
        "wsl",
        "-d",
        "archlinux",
        "--cd",
        "~",
    },
}

M.options = {
    default_prog = M.bash.args,

    launch_menu = {
        M.bash,
        M.powershell,
        M.wsl_arch,
    },
}

return M
