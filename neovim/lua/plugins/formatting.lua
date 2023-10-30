local utils = require("config.utils")
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
        "shellRaining/hlchunk.nvim",
        cmd = {
            "EnableHL",
            "DisableHL",
            "EnableHLChunk",
            "DisableHLChunk",
            "EnableHLIndent",
            "DisableHLIndent",
            "EnableHLLineNum",
            "DisableHLLineNum",
            "EnableHLBlank",
            "DisableHLBlank",
        },
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = function()
            return {
                chunk = {
                    enable = true,
                    notify = false,
                    use_treesitter = true,
                    chars = {
                        horizontal_line = "━",
                        vertical_line = "┃",
                        left_top = "┏",
                        left_bottom = "┗",
                        right_arrow = "━",
                    },
                    style = {
                        { fg = utils.get_highlight("purple", "fg") },
                        { fg = utils.get_highlight("red", "fg") }, -- this fg is used to highlight wrong chunk
                    },
                },
                indent = {
                    enable = true,
                    use_treesitter = false,
                    chars = {
                        "│",
                    },
                },
                line_num = {
                    enable = false,
                },
                blank = {
                    enable = false,
                },
            }
        end,
    },
}
