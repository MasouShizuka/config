local environment = require("utils.environment")
local utils = require("utils")

return {
    {
        "echasnovski/mini.map",
        config = function(_, opts)
            local map = require("mini.map")
            require("mini.map").setup(opts)

            local function open_map()
                vim.schedule(function() map.open() end)
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
        init = function()
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
                    mode = "n",
                    ["<leader>m"] = {
                        name = "+minimap",
                    },
                })
            end
        end,
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
                    callback = vim.schedule_wrap(function() map.refresh({}, { lines = false, scrollbar = false }) end),
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
                                line_hl[#line_hl + 1] = { line = lnum + 1, hl_group = spell_hl }
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
                table.insert(integrations, 4, map.gen_integration.gitsigns())
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
            mappings = { "<c-u>", "<c-d>" },
            hide_cursor = false, -- Hide cursor while scrolling
        },
    },
}
