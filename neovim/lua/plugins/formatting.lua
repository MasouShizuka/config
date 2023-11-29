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
        "lukas-reineke/indent-blankline.nvim",
        config = function(_, opts)
            local highlight = {
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            }
            opts["scope"] = { highlight = highlight }
            require("ibl").setup(opts)

            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        end,
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        main = "ibl",
        opts = {
            exclude = {
                filetypes = variables.skip_filetype_list,
            },
        },
    },

    {
        "nmac427/guess-indent.nvim",
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {},
    },
}
