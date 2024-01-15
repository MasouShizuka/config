local environment = require("utils.environment")
local utils = require("utils")

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

            local function open_map()
                vim.schedule(function()
                    map.open()
                end)
            end
            open_map()

            vim.api.nvim_create_autocmd("TabEnter", {
                callback = function()
                    open_map()
                end,
                desc = "Auto open minimap",
                group = vim.api.nvim_create_augroup("MiniMapAutoOpen", { clear = true }),
            })
        end,
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "<leader>mm", function() require("mini.map").open() end,         desc = "Open map window",                 mode = "n" },
            { "<leader>mr", function() require("mini.map").refresh() end,      desc = "Refresh map window",              mode = "n" },
            { "<leader>mc", function() require("mini.map").close() end,        desc = "Close map window",                mode = "n" },
            { "<leader>mt", function() require("mini.map").toggle() end,       desc = "Toggle map window",               mode = "n" },
            { "<leader>mf", function() require("mini.map").toggle_focus() end, desc = "Toggle focus to/from map window", mode = "n" },
            { "<leader>ms", function() require("mini.map").toggle_side() end,  desc = "Toggle side of map window",       mode = "n" },
        },
        opts = function()
            local map = require("mini.map")

            local function spell(hl_groups)
                if hl_groups == nil then
                    hl_groups = { spell = "SpellBad" }
                end

                vim.api.nvim_create_autocmd("OptionSet", {
                    callback = vim.schedule_wrap(function()
                        map.refresh({}, { lines = false, scrollbar = false })
                    end),
                    desc = "On 'spell' update",
                    group = vim.api.nvim_create_augroup("MiniMapSpell", { clear = true }),
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
                map.gen_integration.diagnostic({
                    error = "DiagnosticError",
                    warn  = "DiagnosticWarn",
                }),
                spell({ spell = "purple" }),
            }
            if utils.is_git() then
                table.insert(integrations, 2, map.gen_integration.gitsigns())
            end

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
