local variables = require("variables")

return {
    {
        "simrat39/rust-tools.nvim",
        cond = not variables.is_vscode,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        ft = { "rust" },
        opts = {},
    },
}
