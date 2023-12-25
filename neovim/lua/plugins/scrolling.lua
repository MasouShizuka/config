local environment = require("utils.environment")

return {
    -- {
    --     "dstein64/nvim-scrollview",
    --     cmd = {
    --         "ScrollViewDisable",
    --         "ScrollViewEnable",
    --         "ScrollViewToggle",
    --         "ScrollViewRefresh",
    --         "ScrollViewNext",
    --         "ScrollViewPrev",
    --         "ScrollViewFirst",
    --         "ScrollViewLast",
    --     },
    --     enabled = not environment.is_vscode,
    --     -- lazy 读取不起作用
    --     -- event = {
    --     --     "BufNewFile",
    --     --     "BufReadPost",
    --     -- },
    --     lazy = false,
    --     opts = {
    --         current_only = true,
    --         excluded_filetypes = filetype.skip_filetype_list,
    --         line_limit = -1,
    --         signs_column = 0,
    --         signs_on_startup = {
    --             "conflicts",
    --             -- "cursor",
    --             "diagnostics",
    --             "folds",
    --             "loclist",
    --             "marks",
    --             "quickfix",
    --             "search",
    --             "spell",
    --             -- "textwidth",
    --             -- "trail",
    --         },
    --         diagnostics_error_symbol = icons.diagnostics.Error,
    --         diagnostics_severities = {
    --             vim.diagnostic.severity.ERROR,
    --             vim.diagnostic.severity.WARN,
    --         },
    --         diagnostics_warn_symbol = icons.diagnostics.Warn,
    --     },
    -- },

    {
        "echasnovski/mini.map",
        config = function(_, opts)
            local map = require("mini.map")
            require("mini.map").setup(opts)
            vim.schedule(function()
                map.open()
            end)
        end,
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = function()
            local map = require("mini.map")

            local function spell(hl_groups)
                if hl_groups == nil then
                    hl_groups = { spell = "SpellBad" }
                end

                local augroup = vim.api.nvim_create_augroup("MiniMapSpell", {})
                vim.api.nvim_create_autocmd("OptionSet", {
                    callback = vim.schedule_wrap(function()
                        map.refresh({}, { lines = false, scrollbar = false })
                    end),
                    desc = "On 'spell' update",
                    group = augroup,
                    pattern = { "dictionary", "spell" },
                })

                local spell_hl = hl_groups.spell

                return function()
                    local line_hl = {}

                    local spell = vim.api.nvim_get_option_value("spell", { scope = "local" })
                    if spell then
                        local lines = vim.api.nvim_buf_get_lines(map.current.buf_data.source, 0, -1, false)
                        for lnum, line in ipairs(lines) do
                            local spellbadword = vim.fn.spellbadword(line)
                            if spellbadword[1] ~= "" then
                                table.insert(line_hl, { line = lnum + 1, hl_group = spell_hl })
                            end
                        end
                    end

                    return line_hl
                end
            end

            local integrations = {
                map.gen_integration.builtin_search({ search = "green" }),
                map.gen_integration.gitsigns(),
                map.gen_integration.diagnostic({
                    error = "DiagnosticError",
                    warn  = "DiagnosticWarn",
                    info  = "DiagnosticInfo",
                    hint  = "DiagnosticHint",
                }),
                spell({ spell = "purple" }),
            }

            return {
                integrations = integrations,
                window = {
                    show_integration_count = false,
                    width = 2,
                    winblend = 0,
                    zindex = 40,
                },

            }
        end,
        version = false,
    },

    {
        "karb94/neoscroll.nvim",
        config = function(_, opts)
            require("neoscroll").setup(opts)

            local t = {}
            -- Syntax: t[keys] = {function, {function arguments}}
            -- t["<c-u>"] = {"scroll", {"-vim.wo.scroll", "true", "250"}}
            -- t["<c-d>"] = {"scroll", { "vim.wo.scroll", "true", "250"}}
            t["<c-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100" } }
            t["<c-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } }
            -- t["<c-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } }
            -- t["<c-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } }
            -- t["<c-y>"] = { "scroll", { "-0.10", "false", "100" } }
            -- t["<c-e>"] = { "scroll", { "0.10", "false", "100" } }
            -- t["zt"]    = { "zt", { "250" } }
            -- t["zz"]    = { "zz", { "250" } }
            -- t["zb"]    = { "zb", { "250" } }

            require("neoscroll.config").set_mappings(t)
        end,
        enabled = not environment.is_vscode,
        keys = {
            { "<c-u>", desc = "Scroll half page up",   mode = { "n", "x" } },
            { "<c-d>", desc = "Scroll half page down", mode = { "n", "x" } },
        },
        opts = {
            -- All these keys will be mapped to their corresponding default scrolling animation
            -- mappings = { "<c-u>", "<c-d>", "<c-b>", "<c-f>", "<c-y>", "<c-e>", "zt", "zz", "zb" },
            mappings = { "<c-u>", "<c-d>" },
            -- hide_cursor = true,       -- Hide cursor while scrolling
            hide_cursor = false,
            stop_eof = true,             -- Stop at <EOF> when scrolling downwards
            respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
            cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
            easing_function = nil,       -- Default easing function
            pre_hook = nil,              -- Function to run before the scrolling animation starts
            post_hook = nil,             -- Function to run after the scrolling animation ends
            performance_mode = false,    -- Disable "Performance Mode" on all buffers.
        },
    },
}
