local environment = require("utils.environment")
local filetype = require("utils.filetype")
local format = require("utils.format")

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

    {
        "lukas-reineke/indent-blankline.nvim",
        -- 严重影响性能，因此不启用 rainbow-delimiters integration
        -- config = function(_, opts)
        --     if utils.is_available("rainbow-delimiters.nvim") then
        --         local highlight = {
        --             "RainbowDelimiterRed",
        --             "RainbowDelimiterYellow",
        --             "RainbowDelimiterBlue",
        --             "RainbowDelimiterOrange",
        --             "RainbowDelimiterGreen",
        --             "RainbowDelimiterViolet",
        --             "RainbowDelimiterCyan",
        --         }
        --         opts["scope"] = { highlight = highlight }

        --         local hooks = require("ibl.hooks")
        --         hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        --     end
        --     require("ibl").setup(opts)
        -- end,
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        main = "ibl",
        opts = {
            exclude = {
                filetypes = filetype.skip_filetype_list,
            },
        },
    },

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
