local variables = require("variables")

return {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
    cond = not variables.is_vscode,
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        { "<CR>", mode = "n" },
        { "<BS>", mode = "x" },
    },
    opts = {
        ensure_installed = {
            "bash",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "rust",
        },
        highlight = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",
                node_decremental = "<BS>",
                node_incremental = "<CR>",
                scope_incremental = "<NOP>",
            },
        },
        indent = { enable = true },
    },
    version = false,
}
