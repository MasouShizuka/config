local colors = require("utils.colors")
local environment = require("utils.environment")
local utils = require("utils")

return {
    {
        "echasnovski/mini.map",
        config = function(_, opts)
            local map = require("mini.map")
            require("mini.map").setup(opts)

            if vim.g.minimap_enabled == nil then
                vim.g.minimap_enabled = true
            end

            local function open_map()
                local buf = vim.api.nvim_get_current_buf()
                if vim.b[buf].minimap_enabled == nil and vim.g.minimap_enabled or vim.b[buf].minimap_enabled then
                    vim.schedule(function() map.open() end)
                else
                    vim.schedule(function() map.close() end)
                end
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
            if utils.is_available("which-key.nvim") then
                require("which-key").add({
                    { "<leader>m", group = "minimap", mode = "n" },
                })
            end
        end,
        keys = {
            {
                "<leader>mm",
                function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.g.minimap_enabled = true
                    if vim.b[buf].minimap_enabled ~= false then
                        require("mini.map").open()
                    end
                end,
                desc = "Open map window",
                mode = "n",
            },
            {
                "<leader>mM",
                function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.b[buf].minimap_enabled = true
                    require("mini.map").open()
                end,
                desc = "Open map window (buffer)",
                mode = "n",
            },
            { "<leader>mr", function() require("mini.map").refresh() end,      desc = "Refresh map window",              mode = "n" },
            {
                "<leader>mq",
                function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.g.minimap_enabled = false
                    if vim.b[buf].minimap_enabled ~= true then
                        require("mini.map").close()
                    end
                end,
                desc = "Close map window",
                mode = "n",
            },
            {
                "<leader>mQ",
                function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.b[buf].minimap_enabled = false
                    require("mini.map").close()
                end,
                desc = "Close map window (buffer)",
                mode = "n",
            },
            {
                "<leader>mt",
                function()
                    local map = require("mini.map")
                    utils.toggle_global_setting("minimap_enabled", function(enabled, prev_enabled, global_enabled)
                        if prev_enabled == enabled then
                            return
                        end

                        if enabled then
                            vim.schedule(function() map.open() end)
                        else
                            vim.schedule(function() map.close() end)
                        end
                    end)
                end,
                desc = "Toggle map window",
                mode = "n",
            },
            {
                "<leader>mT",
                function()
                    local map = require("mini.map")
                    utils.toggle_buffer_setting("minimap_enabled", function(enabled, prev_enabled)
                        if prev_enabled == enabled then
                            return
                        end

                        if enabled then
                            vim.schedule(function() map.open() end)
                        else
                            vim.schedule(function() map.close() end)
                        end
                    end)
                end,
                desc = "Toggle map window (buffer)",
                mode = "n",
            },
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
                                line_hl[#line_hl + 1] = { line = lnum, hl_group = spell_hl }
                            end
                        end
                    end

                    return line_hl
                end
            end

            local minimap_search = "MiniMapSearch"
            local minimap_spell = "MiniMapSpell"
            local function set_hl()
                vim.api.nvim_set_hl(0, minimap_search, { fg = colors.get_color(colors.colors.green) })
                vim.api.nvim_set_hl(0, minimap_spell, { fg = colors.get_color(colors.colors.purple) })
            end

            set_hl()
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    set_hl()
                end,
                desc = "Set hl for minimap",
                group = vim.api.nvim_create_augroup("MiniMapHighlight", { clear = true }),
            })

            local integrations = {
                map.gen_integration.builtin_search({ search = minimap_search }),
                map.gen_integration.diagnostic({
                    error = "DiagnosticError",
                    warn  = "DiagnosticWarn",
                }),
                spell({ spell = minimap_spell }),
            }
            if utils.is_git() then
                table.insert(integrations, 4, map.gen_integration.gitsigns())
            end

            return {
                -- Highlight integrations (none by default)
                integrations = integrations,

                -- Window options
                window = {
                    -- Whether to show count of multiple integration highlights
                    show_integration_count = false,

                    -- Total width
                    width = 2,

                    -- Value of 'winblend' option
                    winblend = 0,

                    -- Z-index
                    zindex = 40,
                },

            }
        end,
    },

    {
        "karb94/neoscroll.nvim",
        enabled = not environment.is_vscode,
        keys = {
            {
                "<c-u>",
                function()
                    require("neoscroll").ctrl_u({ duration = 100 })
                end,
                desc = "Scroll half page up",
                mode = { "n", "x" },
            },
            {
                "<c-d>",
                function()
                    require("neoscroll").ctrl_d({ duration = 100 })
                end,
                desc = "Scroll half page down",
                mode = { "n", "x" },
            },
            { "zj", function() require("neoscroll").zt({ half_win_duration = 100 }) end, desc = "Top this line",    mode = { "n", "x" } },
            { "zz", function() require("neoscroll").zz({ half_win_duration = 100 }) end, desc = "Center this line", mode = { "n", "x" } },
            { "zk", function() require("neoscroll").zb({ half_win_duration = 100 }) end, desc = "Bottom this line", mode = { "n", "x" } },
        },
        opts = {
            -- All these keys will be mapped to their corresponding default scrolling animation
            mappings = {},
            hide_cursor = false, -- Hide cursor while scrolling
        },
    },
}
