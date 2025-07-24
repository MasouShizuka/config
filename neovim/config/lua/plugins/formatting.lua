local environment = require("utils.environment")

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
                    -- start = "ga",
                    -- start_with_preview = "gA",
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
        config = function(_, opts)
            if require("utils").is_available("rainbow-delimiters.nvim") then
                local colors = require("utils.colors")

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
        opts = function()
            return {
                exclude = {
                    buftypes = require("utils.buftype").skip_buftype_list,
                    filetypes = require("utils.filetype").skip_filetype_list,
                },
            }
        end,
    },

    {
        "NMAC427/guess-indent.nvim",
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        opts = function()
            return {
                -- A list of filetypes for which the auto command gets disabled
                filetype_exclude = require("utils.filetype").skip_filetype_list,
                -- A list of buffer types for which the auto command gets disabled
                buftype_exclude = require("utils.buftype").skip_buftype_list,
            }
        end,
    },

    {
        "stevearc/conform.nvim",
        cmd = {
            "ConformInfo",
        },
        dependencies = {
            "williamboman/mason.nvim",
        },
        enabled = not environment.is_vscode and environment.format_enable,
        init = function()
            local utils = require("utils")
            utils.create_once_autocmd("User", {
                callback = function()
                    if utils.is_available("which-key.nvim") then
                        require("which-key").add({
                            { "<leader>ltf", group = "toggle format", mode = "n" },
                        })
                    end

                    local function format(setting, opts)
                        opts.buf = opts.buf or vim.api.nvim_get_current_buf()

                        local buf = opts.buf

                        local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buf })
                        if not is_modifiable then
                            return
                        end

                        local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                        if vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) then
                            return
                        end

                        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                        if vim.tbl_contains(require("utils.filetype").skip_filetype_list, ft) then
                            return
                        end

                        if utils.get_setting_condition(setting, { buf = buf }) then
                            require("conform").format(opts)
                        end
                    end

                    local augroup = vim.api.nvim_create_augroup("ConformAutoFormat", { clear = true })
                    utils.set_setting_toggle("autoformat_on_save", {
                        default = false,
                        init = function()
                            vim.api.nvim_create_autocmd("BufWritePre", {
                                callback = function(args)
                                    format("autoformat_on_save", { bufnr = args.buf })
                                end,
                                desc = "Autoformat on save",
                                group = augroup,
                            })
                        end,
                        g = {
                            keymap = { keys = "<leader>ltfs", mode = "n" },
                            opts = {
                                callback = function()
                                    if not package.loaded["conform"] then
                                        require("lazy").load({ plugins = "conform.nvim" })
                                    end
                                end,
                            },
                        },
                        b = {
                            keymap = { keys = "<leader>ltfS", mode = "n" },
                            opts = {
                                callback = function()
                                    if not package.loaded["conform"] then
                                        require("lazy").load({ plugins = "conform.nvim" })
                                    end
                                end,
                            },
                        },
                    })
                    utils.set_setting_toggle("autoformat_on_quit", {
                        default = false,
                        init = function()
                            vim.api.nvim_create_autocmd("QuitPre", {
                                callback = function(args)
                                    format("autoformat_on_quit", { bufnr = args.buf })
                                end,
                                desc = "Autoformat on quit",
                                group = augroup,
                            })
                        end,
                        g = {
                            keymap = { keys = "<leader>ltfq", mode = "n" },
                            opts = {
                                callback = function()
                                    if not package.loaded["conform"] then
                                        require("lazy").load({ plugins = "conform.nvim" })
                                    end
                                end,
                            },
                        },
                        b = {
                            keymap = { keys = "<leader>ltfQ", mode = "n" },
                            opts = {
                                callback = function()
                                    if not package.loaded["conform"] then
                                        require("lazy").load({ plugins = "conform.nvim" })
                                    end
                                end,
                            },
                        },
                    })
                end,
                desc = "Toggle autoformat_on_save",
                pattern = "IceLoad",
            })
        end,
        keys = {
            { "<leader>f", function() require("conform").format() end, desc = "Buffer Diagnostics (Trouble)", mode = "n" },
        },
        opts = function()
            local formatters = {}
            for formatter, config in pairs(require("utils.format").format_config) do
                formatters[formatter] = config
            end

            return {
                -- Map of filetype to formatters
                formatters_by_ft = require("utils.format").formatters_by_ft,
                -- Set this to change the default values when calling conform.format()
                -- This will also affect the default values for format_on_save/format_after_save
                default_format_opts = {
                    timeout_ms = 5000,
                    lsp_format = "first",
                },
                -- Custom formatters and overrides for built-in formatters
                formatters = formatters,
            }
        end,
    },
}
