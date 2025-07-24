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
    --         "ScrollViewLegend",
    --     },
    --     config = function(_, opts)
    --         require("scrollview").setup(opts)
    --
    --         if require("utils").is_available("gitsigns.nvim") then
    --             vim.api.nvim_create_autocmd("User", {
    --                 callback = function()
    --                     require("scrollview.contrib.gitsigns").setup()
    --                 end,
    --                 desc = "Register gitsigns for scrollview",
    --                 group = vim.api.nvim_create_augroup("ScrollviewGitsigns", { clear = true }),
    --                 pattern = "GitFile",
    --             })
    --         end
    --     end,
    --     enabled = not environment.is_vscode,
    --     event = {
    --         "User IceLoad",
    --     },
    --     opts = function()
    --         return {
    --             byte_limit = -1,
    --             current_only = true,
    --             excluded_filetypes = require("utils.filetype").skip_filetype_list,
    --             line_limit = -1,
    --             signs_on_startup = {
    --                 "changelist",
    --                 "conflicts",
    --                 -- "cursor",
    --                 "diagnostics",
    --                 "folds",
    --                 "latestchange",
    --                 "loclist",
    --                 "marks",
    --                 "quickfix",
    --                 "search",
    --                 "spell",
    --                 -- "textwidth",
    --                 -- "trail",
    --             },
    --             diagnostics_severities = {
    --                 vim.diagnostic.severity.ERROR,
    --                 vim.diagnostic.severity.WARN,
    --             },
    --         }
    --     end,
    -- },

    {
        "echasnovski/mini.map",
        config = function(_, opts)
            local map = require("mini.map")
            map.setup(opts)

            if vim.g.minimap == nil then
                vim.g.minimap = true
            end

            local function open_map()
                if require("utils").get_setting_condition("minimap") then
                    vim.schedule(function() map.open() end)
                else
                    vim.schedule(function() map.close() end)
                end
            end

            open_map()
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = open_map,
                desc = "Auto open minimap",
                group = vim.api.nvim_create_augroup("MiniMapAutoOpen", { clear = true }),
            })
        end,
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        init = function()
            local utils = require("utils")

            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function(args)
                    local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
                    if vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) then
                        vim.b[args.buf].minimap_disable = true
                        return
                    end

                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if vim.tbl_contains(require("utils.filetype").skip_filetype_list, ft) then
                        vim.b[args.buf].minimap_disable = true
                    end
                end,
                desc = "Disable mini.map for some buftypes and filetypes",
                group = vim.api.nvim_create_augroup("MiniMapDisable", { clear = true }),
            })

            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>m", group = "minimap", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for mini.minimap",
                    pattern = "IceLoad",
                })
            end

            utils.create_once_autocmd("User", {
                callback = function()
                    utils.set_setting_toggle("minimap", {
                        default = true,
                        g = {
                            keymap = { keys = "<leader>mt", mode = "n" },
                            opts = {
                                callback = function(enabled, prev_enabled, global_enabled)
                                    if prev_enabled == enabled then
                                        return
                                    end

                                    local map = require("mini.map")
                                    if enabled then
                                        vim.schedule(function() map.open() end)
                                    else
                                        vim.schedule(function() map.close() end)
                                    end
                                end,
                            },
                        },
                        b = {
                            keymap = { keys = "<leader>mT", mode = "n" },
                            opts = {
                                callback = function(enabled, prev_enabled, global_enabled)
                                    if prev_enabled == enabled then
                                        return
                                    end

                                    local map = require("mini.map")
                                    if enabled then
                                        vim.schedule(function() map.open() end)
                                    else
                                        vim.schedule(function() map.close() end)
                                    end
                                end,
                            },
                        },
                    })
                end,
                desc = "Toggle mini.minimap",
                pattern = "IceLoad",
            })
        end,
        keys = {
            {
                "<leader>mm",
                function()
                    local buf = vim.api.nvim_get_current_buf()
                    vim.g.minimap = true
                    if vim.b[buf].minimap ~= false then
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
                    vim.b[buf].minimap = true
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
                    vim.g.minimap = false
                    if vim.b[buf].minimap ~= true then
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
                    vim.b[buf].minimap = false
                    require("mini.map").close()
                end,
                desc = "Close map window (buffer)",
                mode = "n",
            },
            { "<leader>mf", function() require("mini.map").toggle_focus() end, desc = "Toggle focus to/from map window", mode = "n" },
            { "<leader>ms", function() require("mini.map").toggle_side() end,  desc = "Toggle side of map window",       mode = "n" },
        },
        opts = function()
            local colors = require("utils.colors")
            local icons = require("utils.icons")
            local utils = require("utils")

            local map = require("mini.map")

            map.encode_strings = function(strings, opts)
                local source_rows = vim.api.nvim_buf_line_count(0)
                local linenr = vim.api.nvim_win_get_cursor(0)[1]

                local n_rows = math.min(source_rows, vim.api.nvim_win_get_height(0))

                local res = {}
                for _ = 1, n_rows do
                    res[#res + 1] = icons.misc.right_five_eighths_block
                end

                local rows_coeff = n_rows / source_rows
                local row = math.floor((linenr - 1) * rows_coeff) + 1
                res[row] = icons.misc.full_block

                return res
            end

            local function cursor()
                vim.api.nvim_create_autocmd("CursorMoved", {
                    callback = vim.schedule_wrap(function() map.refresh({}, { lines = true, scrollbar = false }) end),
                    desc = "On 'cursor' update",
                    group = vim.api.nvim_create_augroup("MiniMapCursor", { clear = true }),
                })

                return function()
                    return { { line = vim.api.nvim_win_get_cursor(0)[1], hl_group = "MiniMapSymbolLine" } }
                end
            end

            local function search()
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

                local minimap_search = "MiniMapSearch"
                utils.set_hl(0, minimap_search, function() return { fg = colors.get_color(colors.colors.orange) } end)
                return map.gen_integration.builtin_search({ search = minimap_search })
            end

            local function spell()
                vim.api.nvim_create_autocmd("OptionSet", {
                    callback = vim.schedule_wrap(function() map.refresh({}, { lines = false, scrollbar = false }) end),
                    desc = "On 'spell' update",
                    group = vim.api.nvim_create_augroup("MiniMapSpell", { clear = true }),
                    pattern = { "dictionary", "spell" },
                })

                local minimap_spell = "MiniMapSpell"
                utils.set_hl(0, minimap_spell, function() return { fg = colors.get_color(colors.colors.purple) } end)
                return function()
                    local line_hl = {}

                    if vim.api.nvim_get_option_value("spell", { scope = "local" }) then
                        local lines = vim.api.nvim_buf_get_lines(map.current.buf_data.source, 0, -1, false)
                        for lnum, line in ipairs(lines) do
                            local spellbadword = vim.fn.spellbadword(line)
                            if spellbadword[1] ~= "" then
                                line_hl[#line_hl + 1] = { line = lnum, hl_group = minimap_spell }
                            end
                        end
                    end

                    return line_hl
                end
            end

            local integrations = {
                cursor(),
                search(),
                map.gen_integration.diff({
                    add = "DiffAdd",
                    change = "DiffChange",
                    delete = "DiffDelete",
                }),
                map.gen_integration.diagnostic({
                    error = "DiagnosticError",
                    warn  = "DiagnosticWarn",
                }),
                spell(),
            }
            if utils.is_git() then
                table.insert(integrations, 4, map.gen_integration.gitsigns())
            end

            return {
                -- Highlight integrations (none by default)
                integrations = integrations,

                -- Symbols used to display data
                symbols = {
                    -- Encode symbols. See `:h MiniMap.config` for specification and
                    -- `:h MiniMap.gen_encode_symbols` for pre-built ones.
                    -- Default: solid blocks with 3x2 resolution.
                    encode = { icons.misc.full_block, icons.misc.full_block, resolution = { row = 1, col = 1 } },

                    -- Scrollbar parts for view and line. Use empty string to disable any.
                    scroll_line = "",
                    scroll_view = "",
                },

                -- Window options
                window = {
                    -- Whether to show count of multiple integration highlights
                    show_integration_count = false,

                    -- Total width
                    width = 1,

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
            { "<c-u>", function() require("neoscroll").ctrl_u({ duration = 100 }) end,      desc = "Scroll half page up",   mode = { "n", "x" } },
            { "<c-d>", function() require("neoscroll").ctrl_d({ duration = 100 }) end,      desc = "Scroll half page down", mode = { "n", "x" } },
            { "zj",    function() require("neoscroll").zt({ half_win_duration = 100 }) end, desc = "Top this line",         mode = { "n", "x" } },
            { "zz",    function() require("neoscroll").zz({ half_win_duration = 100 }) end, desc = "Center this line",      mode = { "n", "x" } },
            { "zk",    function() require("neoscroll").zb({ half_win_duration = 100 }) end, desc = "Bottom this line",      mode = { "n", "x" } },
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
