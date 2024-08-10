local colors = require("utils.colors")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local format = require("utils.format")
local icons = require("utils.icons")
local utils = require("utils")

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
        opts = function()
            local align = require("mini.align")
            return {
                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    start = "ga",
                    start_with_preview = "gA",
                },

                -- Modifiers changing alignment steps and/or options
                modifiers = {
                    ["T"] = function(steps, opts)
                        table.insert(steps.pre_justify, align.gen_step.trim())
                        opts.merge_delimiter = " "
                    end,
                },
            }
        end,
    },

    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     config = function(_, opts)
    --         if utils.is_available("rainbow-delimiters.nvim") then
    --             local highlight = {
    --                 "RainbowDelimiterRed",
    --                 "RainbowDelimiterYellow",
    --                 "RainbowDelimiterBlue",
    --                 "RainbowDelimiterOrange",
    --                 "RainbowDelimiterGreen",
    --                 "RainbowDelimiterViolet",
    --                 "RainbowDelimiterCyan",
    --             }
    --             opts.scope = { highlight = highlight }
    --
    --             local hooks = require("ibl.hooks")
    --             -- create the highlight groups in the highlight setup hook, so they are reset
    --             -- every time the colorscheme changes
    --             hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.get_color("red") })
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = colors.get_color("yellow") })
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = colors.get_color("blue") })
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = colors.get_color("orange") })
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = colors.get_color("green") })
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = colors.get_color("purple") })
    --                 vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = colors.get_color("cyan") })
    --             end)
    --             hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    --         end
    --         require("ibl").setup(opts)
    --     end,
    --     enabled = not environment.is_vscode,
    --     event = {
    --         "BufNewFile",
    --         "BufReadPost",
    --     },
    --     main = "ibl",
    --     opts = {
    --         exclude = {
    --             filetypes = filetype.skip_filetype_list,
    --         },
    --     },
    -- },

    {
        "nmac427/guess-indent.nvim",
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {},
    },

    {
        "nvimdev/indentmini.nvim",
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {
            char = icons.misc.left_one_quarter_block,
            exclude = filetype.skip_filetype_list,
        },
    },

    {
        "stevearc/conform.nvim",
        cmd = {
            "ConformInfo",
        },
        enabled = not environment.is_vscode,
        lazy = true,
        opts = function()
            local formatters = {}
            for formatter, config in pairs(format.format) do
                if config then
                    formatters[formatter] = config
                end
            end

            return {
                -- Map of filetype to formatters
                formatters_by_ft = format.formatters_by_ft,
                -- Set the log level. Use `:ConformInfo` to see the location of the log file.
                log_level = vim.log.levels.OFF,
                -- Custom formatters and overrides for built-in formatters
                formatters = formatters,
            }
        end,
    },
}
