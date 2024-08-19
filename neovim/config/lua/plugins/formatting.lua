local buftype = require("utils.buftype")
local colors = require("utils.colors")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local format = require("utils.format")
local icons = require("utils.icons")
local utils = require("utils")

return {
    {
        "echasnovski/mini.align",
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
        "echasnovski/mini.indentscope",
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "ii", mode = { "x", "o" } },
            { "ai", mode = { "x", "o" } },
            { "]i", mode = { "n", "x", "o" } },
            { "[i", mode = { "n", "x", "o" } },
        },
        opts = function()
            return {
                draw = {
                    -- Delay (in ms) between event and start of drawing scope indicator
                    delay = 0,

                    -- Animation rule for scope's first drawing. A function which, given
                    -- next and total step numbers, returns wait time (in ms). See
                    -- |MiniIndentscope.gen_animation| for builtin options. To disable
                    -- animation, use `require('mini.indentscope').gen_animation.none()`.
                    --<function: implements constant 20ms between steps>
                    animation = require("mini.indentscope").gen_animation.none(),
                },

                -- Options which control scope computation
                options = {
                    -- Type of scope's border: which line(s) with smaller indent to
                    -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
                    border = "top",
                },

                -- Which character to use for drawing scope indicator
                symbol = icons.misc.left_one_quarter_block,
            }
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        config = function(_, opts)
            if utils.is_available("rainbow-delimiters.nvim") then
                local highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                }
                opts.scope = { highlight = highlight }

                local hooks = require("ibl.hooks")
                -- create the highlight groups in the highlight setup hook, so they are reset
                -- every time the colorscheme changes
                hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                    vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = colors.get_color("red") })
                    vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = colors.get_color("yellow") })
                    vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = colors.get_color("blue") })
                    vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = colors.get_color("orange") })
                    vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = colors.get_color("green") })
                    vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = colors.get_color("purple") })
                    vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = colors.get_color("cyan") })
                end)
                hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
            end
            require("ibl").setup(opts)
        end,
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        main = "ibl",
        opts = {
            exclude = {
                buftypes = buftype.skip_buftype_list,
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
        config = function(_, opts)
            require("conform").setup(opts)

            if vim.g.autoformat_enabled == nil then
                vim.g.autoformat_enabled = false
            end

            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function(args)
                    if vim.b[args.buf].autoformat_enabled == nil and vim.g.autoformat_enabled or vim.b[args.buf].autoformat_enabled then
                        require("conform").format()
                    end
                end,
                desc = "Autoformat on save",
                group = vim.api.nvim_create_augroup("ConformAutoFormat", { clear = true }),
            })
        end,
        enabled = not environment.is_vscode,
        keys = {
            { "<leader>f",   function() require("conform").format() end,                                                                            desc = "Buffer Diagnostics (Trouble)",   mode = "n" },
            { "<leader>ltf", function() utils.toggle_global_setting("autoformat_enabled", function(enabled, prev_enabled, global_enabled) end) end, desc = "Toggle autoformatting",          mode = "n" },
            { "<leader>ltF", function() utils.toggle_buffer_setting("autoformat_enabled", function(enabled, prev_enabled) end) end,                 desc = "Toggle autoformatting (buffer)", mode = "n" },
        },
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
                -- Set this to change the default values when calling conform.format()
                -- This will also affect the default values for format_on_save/format_after_save
                default_format_opts = {
                    timeout_ms = 5000,
                    lsp_format = "fallback",
                },
                -- Custom formatters and overrides for built-in formatters
                formatters = formatters,
            }
        end,
    },
}
