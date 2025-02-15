local buftype = require("utils.buftype")
local colors = require("utils.colors")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
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
    --         "ScrollViewLegend",
    --     },
    --     config = function(_, opts)
    --         require("scrollview").setup(opts)
    --
    --         if utils.is_available("gitsigns.nvim") then
    --             vim.api.nvim_create_autocmd("User", {
    --                 callback = function()
    --                     require("scrollview.contrib.gitsigns").setup()
    --                 end,
    --                 desc = "description",
    --                 group = vim.api.nvim_create_augroup("ScrollviewGitsigns", { clear = true }),
    --                 pattern = "GitFile",
    --             })
    --         end
    --     end,
    --     enabled = not environment.is_vscode,
    --     event = {
    --         "BufNewFile",
    --         "BufReadPost",
    --     },
    --     opts = {
    --         byte_limit = -1,
    --         current_only = true,
    --         excluded_filetypes = filetype.skip_filetype_list,
    --         line_limit = -1,
    --         signs_on_startup = {
    --             "changelist",
    --             "conflicts",
    --             -- "cursor",
    --             "diagnostics",
    --             "folds",
    --             "latestchange",
    --             "loclist",
    --             "marks",
    --             "quickfix",
    --             "search",
    --             "spell",
    --             -- "textwidth",
    --             -- "trail",
    --         },
    --         diagnostics_severities = {
    --             vim.diagnostic.severity.ERROR,
    --             vim.diagnostic.severity.WARN,
    --         },
    --     },
    -- },

    {
        "echasnovski/mini.map",
        config = function(_, opts)
            local map = require("mini.map")
            map.setup(opts)

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

            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function(args)
                    local buf = args.buf

                    local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                    if vim.tbl_contains(buftype.skip_buftype_list, bt) and bt ~= "help" then
                        vim.b[buf].minimap_disable = true
                        return
                    end

                    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    if vim.tbl_contains(filetype.skip_filetype_list, ft) then
                        vim.b[buf].minimap_disable = true
                    end
                end,
                desc = "Disable mini.map for some buftypes and filetypes",
                group = vim.api.nvim_create_augroup("MiniMapDisable", { clear = true }),
            })

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

            utils.set_hl(0, minimap_search, { fg = colors.get_color(colors.colors.orange) })
            utils.set_hl(0, minimap_spell, { fg = colors.get_color(colors.colors.purple) })

            local integrations = {
                map.gen_integration.builtin_search({ search = minimap_search }),
                map.gen_integration.diff({
                    add = "DiffAdd",
                    change = "DiffChange",
                    delete = "DiffDelete",
                }),
                map.gen_integration.diagnostic({
                    error = "DiagnosticError",
                    warn  = "DiagnosticWarn",
                }),
                spell({ spell = minimap_spell }),
            }
            if utils.is_git() then
                table.insert(integrations, 4, map.gen_integration.gitsigns())
            end

            -- It's possible that <cmd>nohlsearch<cr> was executed from a mapping, and
            -- wouldn't be handled by the CmdlineLeave callback above. Use a CursorMoved
            -- event to check if search signs are shown when they shouldn't be, and
            -- update accordingly. Also handle the case where 'n', 'N', '*', '#', 'g*',
            -- or 'g#' are pressed (although these won't be properly handled when there
            -- is only one search result and the cursor is already on it, since the
            -- cursor wouldn't move; creating scrollview refresh mappings for those keys
            -- could handle that scenario). NOTE: If there are scenarios where search
            -- signs become out of sync (i.e., shown when they shouldn't be), this same
            -- approach could be used with a timer.
            vim.api.nvim_create_autocmd("CursorMoved", {
                callback = function()
                    -- Use defer_fn since vim.v.hlsearch may not have been properly set yet.
                    vim.defer_fn(function()
                        local refresh = false
                        if vim.v.hlsearch ~= 0 then
                            local searchcount_total = 0
                            pcall(function()
                                -- searchcount() can return {} (e.g., when launching Neovim
                                -- with -i NONE).
                                searchcount_total = vim.fn.searchcount().total or 0
                            end)
                            if searchcount_total > 0 then
                                refresh = true
                            end
                        else
                            refresh = true
                        end

                        if refresh then
                            map.refresh({}, { lines = false, scrollbar = false })
                        end
                    end, 0)
                end,
                desc = "On 'search' update",
                group = vim.api.nvim_create_augroup("MiniMapSearch", { clear = true }),
            })

            return {
                -- Highlight integrations (none by default)
                integrations = integrations,

                -- Symbols used to display data
                symbols = {
                    -- Encode symbols. See `:h MiniMap.config` for specification and
                    -- `:h MiniMap.gen_encode_symbols` for pre-built ones.
                    -- Default: solid blocks with 3x2 resolution.
                    encode = map.gen_encode_symbols.block("1x2"),
                },

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
            ignored_events = {   -- Events ignored while scrolling
                "WinScrolled",
            },
        },
    },
}
