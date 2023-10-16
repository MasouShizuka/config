local variables = require("config.variables")

return {
    {
        "echasnovski/mini.align",
        config = function(_, opts)
            require("mini.align").setup(opts)
        end,
        keys = {
            { "ga", desc = "Align",              mode = { "n", "x" } },
            { "gA", desc = "Align with preview", mode = { "n", "x" } },
        },
        opts = {
            mappings = {
                start = "ga",
                start_with_preview = "gA",
            },
        },
        version = false,
    },

    {
        "nvimdev/indentmini.nvim",
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {
            char = "│",
        },
    },
}
