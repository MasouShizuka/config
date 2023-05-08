local variables = require("variables")

return {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = {
        "Mason",
        "MasonUpdate",
        "MasonInstall",
        "MasonUninstall",
        "MasonUninstallAll",
        "MasonLog",
    },
    cond = not variables.is_vscode,
    opts = {
        install_root_dir = vim.fn.stdpath("data") .. "/lazy/mason.nvim/mason/",
        ui = {
            border = "rounded",
        },
    },
}
