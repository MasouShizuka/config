local variables = require("config.variables")

return {
    {
        "anuvyklack/windows.nvim",
        cmd = {
            "WindowsMaximize",
            "WindowsMaximizeVertical",
            "WindowsMaximizeHorizont",
            "WindowsEqualize",
            "WindowsToggleAutowidth",
        },
        dependencies = {
            "anuvyklack/middleclass",
        },
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "<c-s><c-m>", function() vim.api.nvim_command("WindowsMaximize") end,             desc = "Maximize current window",                 mode = "n" },
            { "<c-s><c-c>", function() vim.api.nvim_command("WindowsMaximizeVertically") end,   desc = "Maximize width of the current window",    mode = "n" },
            { "<c-s><c-r>", function() vim.api.nvim_command("WindowsMaximizeHorizontally") end, desc = "Maximize height of the current window",   mode = "n" },
            { "<c-s><c-e>", function() vim.api.nvim_command("WindowsEqualize") end,             desc = "Equalize all windows heights and widths", mode = "n" },
            { "<c-s><c-t>", function() vim.api.nvim_command("WindowsToggleAutowidth") end,      desc = "Toggle auto-width feature",               mode = "n" },
        },
        opts = {
            autowidth = {
                enable = true,
            },
            ignore = {
                filetype = variables.skip_filetype_list3,
            },
            animation = {
                enable = false,
            },
        },
    },

    {
        "folke/edgy.nvim",
        config = function(_, opts)
            require("edgy").setup(opts)

            local function close_all_wins(pos, toggle_filetype_list)
                local result = false
                for p, edgebar in pairs(require("edgy.config").layout) do
                    if p == pos then
                        if #edgebar.wins > 0 then
                            result = true
                        end

                        for _, win in ipairs(edgebar.wins) do
                            if vim.api.nvim_win_is_valid(win.win) then
                                local buf = vim.api.nvim_win_get_buf(win.win)
                                local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
                                local close_function = toggle_filetype_list[filetype]
                                if close_function and type(close_function) == "function" then
                                    close_function()
                                else
                                    win:close()
                                end
                            end
                        end

                        break
                    end
                end

                return result
            end

            local function focus_nth_win(pos, n)
                for p, edgebar in pairs(require("edgy.config").layout) do
                    if p == pos then
                        if #edgebar.wins >= n then
                            edgebar.wins[n]:focus()
                            return true
                        end

                        break
                    end
                end

                return false
            end

            local prev_tabpage
            local prev_win
            local function toggle(pos, toggle_filetype_list)
                local is_focused, close_function = variables.is_toggle_filetype_focused(toggle_filetype_list, false)
                if is_focused then
                    if not close_all_wins(pos, toggle_filetype_list) then
                        close_function()
                    end
                    require("edgy").close(pos)

                    return
                end

                local callback

                local is_opened, win = variables.is_toggle_filetype_opened(toggle_filetype_list, false)
                if is_opened then
                    callback = function()
                        -- if not focus_nth_win(pos, 1) then
                        --     vim.api.nvim_set_current_win(win)
                        -- end
                        vim.api.nvim_set_current_win(win)
                    end
                else
                    callback = function()
                        require("edgy").open(pos)
                    end
                end

                if not variables.is_in_toggle_filetype_list(vim.bo.filetype) then
                    prev_tabpage = vim.api.nvim_get_current_tabpage()
                    prev_win = vim.api.nvim_get_current_win()
                end

                callback()
            end

            vim.keymap.set("n", variables.keymap["<c-1>"], function()
                toggle("left", variables.toggle_filetype_list1)
            end, { desc = "Focus left panel", silent = true })
            vim.keymap.set("n", variables.keymap["<c-2>"], function()
                -- for _, edgebar in pairs(require("edgy.config").layout) do
                --     if #edgebar.wins > 0 then
                --         require("edgy").goto_main()
                --         return
                --     end
                -- end

                if vim.api.nvim_get_current_tabpage() == prev_tabpage and prev_win then
                    vim.api.nvim_set_current_win(prev_win)
                else
                    variables.skip_filetype(variables.skip_filetype_list1, "W")
                end
            end, { desc = "Focus main editor", silent = true })
            vim.keymap.set("n", variables.keymap["<c-3>"], function()
                local count = vim.v.count
                if count > 0 then
                    vim.api.nvim_command(tostring(count) .. "ToggleTerm")
                    return
                end

                toggle("bottom", variables.toggle_filetype_list2)
            end, { desc = "Focus bottom panel", silent = true })
            vim.keymap.set("n", variables.keymap["<c-4>"], function()
                toggle("right", variables.toggle_filetype_list3)
            end, { desc = "Focus right panel", silent = true })
        end,
        enabled = not variables.is_vscode,
        init = function()
            -- views can only be fully collapsed with the global statusline
            vim.opt.laststatus = 3
            -- Default splitting will cause your main splits to jump when opening an edgebar.
            -- To prevent this, set `splitkeep` to either `screen` or `topline`.
            vim.opt.splitkeep = "screen"
        end,
        keys = {
            { variables.keymap["<c-1>"], desc = "Focus left panel",   mode = "n" },
            { variables.keymap["<c-2>"], desc = "Focus main editor",  mode = "n" },
            { variables.keymap["<c-3>"], desc = "Focus bottom panel", mode = "n" },
            { variables.keymap["<c-4>"], desc = "Focus right panel",  mode = "n" },
        },
        lazy = false,
        opts = {
            left = {
                {
                    ft = "dapui_scopes",
                    size = { width = 0.2 },
                },
                {
                    ft = "dapui_breakpoints",
                    size = { width = 0.2 },
                },
                {
                    ft = "dapui_stacks",
                    size = { width = 0.2 },
                },
                {
                    ft = "dapui_watches",
                    size = { width = 0.2 },
                },
                {
                    ft = "neo-tree",
                    filter = function(buf)
                        return vim.b[buf].neo_tree_source == "filesystem"
                    end,
                    title = "Neo-Tree",
                    size = { width = 0.2, height = 0.7 },
                    pinned = true,
                    open = function()
                        require("neo-tree.sources.manager").close_all()
                        require("neo-tree.command").execute({ dir = vim.fn.getcwd() })
                    end,
                },
                -- {
                --     ft = "neo-tree",
                --     filter = function(buf)
                --         return vim.b[buf].neo_tree_source == "document_symbols"
                --     end,
                --     title = "Neo-Tree Document Symbols",
                --     size = { width = 0.2 },
                --     pinned = true,
                --     open = function()
                --         require("neo-tree.command").execute({
                --             position = "top",
                --             source = "document_symbols",
                --         })
                --     end,
                -- },
                -- {
                --     ft = "NvimTree",
                --     size = { width = 0.2, height = 0.7 },
                --     pinned = true,
                --     open = function() require("nvim-tree.api").tree.open() end,
                -- },
                -- {
                --     ft = "aerial",
                --     title = "Aerial",
                --     size = { width = 0.2 },
                --     pinned = true,
                --     open = function() vim.api.nvim_command("AerialOpen") end,
                -- },
            },
            bottom = {
                {
                    ft = "dap-repl",
                    size = { height = 0.3 },
                },
                {
                    ft = "dapui_console",
                    size = { height = 0.3 },
                },
                {
                    ft = "toggleterm",
                    -- exclude floating windows
                    filter = function(buf, win)
                        return vim.api.nvim_win_get_config(win).relative == ""
                    end,
                    size = { height = 0.3 },
                    pinned = true,
                    open = "ToggleTerm",
                },
                {
                    ft = "Trouble",
                    size = { height = 0.3 },
                },
            },
            right = {
                {
                    ft = "help",
                    -- only show help buffers
                    filter = function(buf)
                        return vim.bo[buf].buftype == "help"
                    end,
                    size = { width = 0.5 },
                },
                {
                    ft = "nvim-docs-view",
                    size = { width = 0.2 },
                    pinned = true,
                    open = "DocsViewToggle",
                },
            },
            animate = {
                enabled = false,
            },
            keys = {
                -- close window
                ["q"] = function(win)
                    win:close()
                end,
                -- hide window
                ["<c-q>"] = function(win)
                    local idx = win.idx

                    local idx_forward = idx + 1
                    local win_forward = win.view.edgebar.wins[idx_forward]
                    while win_forward do
                        if win_forward.visible then
                            win:next({ visible = true, focus = true })
                            win:hide()
                            return
                        end

                        idx_forward = idx_forward + 1
                        win_forward = win.view.edgebar.wins[idx_forward]
                    end

                    local idx_backward = idx - 1
                    local win_backward = win.view.edgebar.wins[idx_backward]
                    while win_backward do
                        if win_backward.visible then
                            win:prev({ visible = true, focus = true })
                            win:hide()
                            return
                        end

                        idx_backward = idx_backward + 1
                        win_backward = win.view.edgebar.wins[idx_backward]
                    end

                    win:hide()
                end,
                -- close sidebar
                ["Q"] = function(win)
                    win.view.edgebar:close()
                end,
                -- next open window
                ["]w"] = function(win)
                    win:next({ visible = true, focus = true })
                end,
                -- previous open window
                ["[w"] = function(win)
                    win:prev({ visible = true, focus = true })
                end,
                -- next loaded window
                ["]W"] = false,
                ["<c-j>"] = function(win)
                    win:next({ pinned = false, focus = true })
                end,
                -- prev loaded window
                ["[W"] = false,
                ["<c-k>"] = function(win)
                    win:prev({ pinned = false, focus = true })
                end,
                -- increase width
                ["<c-w>>"] = false,
                ["<c-right>"] = function(win)
                    win:resize("width", 2)
                end,
                -- decrease width
                ["<c-w><lt>"] = false,
                ["<c-left>"] = function(win)
                    win:resize("width", -2)
                end,
                -- increase height
                ["<c-w>+"] = false,
                ["<c-up>"] = function(win)
                    win:resize("height", 2)
                end,
                -- decrease height
                ["<c-w>-"] = false,
                ["<c-down>"] = function(win)
                    win:resize("height", -2)
                end,
                -- reset all custom sizing
                ["<c-w>="] = false,
            },
        },
    },

    -- {
    --     "nvim-focus/focus.nvim",
    --     cmd = {
    --         "FocusDisable",
    --         "FocusEnable",
    --         "FocusToggle",
    --         "FocusSplitNicely",
    --         "FocusSplitCycle",
    --         "FocusDisableWindow",
    --         "FocusEnableWindow",
    --         "FocusToggleWindow",
    --         "FocusGetDisabledWindows",
    --         "FocusSplitLeft",
    --         "FocusSplitDown",
    --         "FocusSplitUp",
    --         "FocusSplitRight",
    --         "FocusEqualise",
    --         "FocusMaximise",
    --         "FocusMaxOrEqual",
    --     },
    --     config = function(_, opts)
    --         local focus = require("focus")
    --         focus.setup(opts)

    --         local ignore_buftypes = { "nofile", "prompt", "popup" }
    --         local ignore_filetypes = variables.skip_filetype_list3
    --         local augroup = vim.api.nvim_create_augroup("FocusDisable", { clear = true })
    --         vim.api.nvim_create_autocmd("WinEnter", {
    --             callback = function(_)
    --                 if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
    --                     vim.w.focus_disable = true
    --                 else
    --                     vim.w.focus_disable = false
    --                 end
    --             end,
    --             desc = "Disable focus autoresize for BufType",
    --             group = augroup,
    --         })
    --         vim.api.nvim_create_autocmd("FileType", {
    --             callback = function(_)
    --                 if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
    --                     vim.b.focus_disable = true
    --                 else
    --                     vim.b.focus_disable = false
    --                 end
    --             end,
    --             desc = "Disable focus autoresize for FileType",
    --             group = augroup,
    --         })

    --         local is_equalised = false
    --         local is_maximised = false
    --         vim.keymap.set("n", "<c-s><c-t>", function() focus.focus_toggle() end, { desc = "Toggle focus on and off again", silent = true })
    --         vim.keymap.set("n", "<c-s><c-e>", function()
    --             if is_equalised then
    --                 focus.focus_autoresize()
    --             else
    --                 focus.focus_equalise()
    --             end
    --             is_equalised = not is_equalised
    --         end, { desc = "Equalise the splits", silent = true })
    --         vim.keymap.set("n", "<c-s><c-m>", function()
    --             if is_maximised then
    --                 focus.focus_equalise()
    --                 focus.focus_autoresize()
    --             else
    --                 focus.focus_maximise()
    --             end
    --             is_maximised = not is_maximised
    --         end, { desc = "Maximise the focussed window", silent = true })
    --     end,
    --     enabled = not variables.is_vscode,
    --     event = {
    --         "BufNewFile",
    --         "BufReadPost",
    --     },
    --     keys = {
    --         { "<c-s><c-t>", desc = "Toggle focus on and off again", mode = "n" },
    --         { "<c-s><c-e>", desc = "Equalise the splits",           mode = "n" },
    --         { "<c-s><c-m>", desc = "Maximise the focussed window",  mode = "n" },
    --     },
    --     opts = {
    --         ui = {
    --             cursorline = false,
    --             signcolumn = false,
    --         },
    --     },
    --     version = false,
    -- },

    {
        "sindrets/winshift.nvim",
        cmd = {
            "WinShift",
            "WinShift left",
            "WinShift right",
            "WinShift up",
            "WinShift down",
            "WinShift far_left",
            "WinShift far_right",
            "WinShift far_up",
            "WinShift far_down",
            "WinShift swap",
        },
        enabled = not variables.is_vscode,
        keys = {
            { "<c-s><c-h>", function() vim.api.nvim_command("WinShift left") end,      desc = "Move window to left",                  mode = "n" },
            { "<c-s><c-l>", function() vim.api.nvim_command("WinShift right") end,     desc = "Move window to right",                 mode = "n" },
            { "<c-s><c-j>", function() vim.api.nvim_command("WinShift down") end,      desc = "Move window to down",                  mode = "n" },
            { "<c-s><c-k>", function() vim.api.nvim_command("WinShift up") end,        desc = "Move window to up",                    mode = "n" },
            { "<c-s>H",     function() vim.api.nvim_command("WinShift far_left") end,  desc = "Move window to far left",              mode = "n" },
            { "<c-s>L",     function() vim.api.nvim_command("WinShift far_right") end, desc = "Move window to far right",             mode = "n" },
            { "<c-s>J",     function() vim.api.nvim_command("WinShift far_down") end,  desc = "Move window to far down",              mode = "n" },
            { "<c-s>K",     function() vim.api.nvim_command("WinShift far_up") end,    desc = "Move window to far up",                mode = "n" },
            { "<c-s><c-s>", function() vim.api.nvim_command("WinShift swap") end,      desc = "Swap the current window with another", mode = "n" },
        },
        opts = {
            ---A function that should prompt the user to select a window.
            ---
            ---The window picker is used to select a window while swapping windows with
            ---`:WinShift swap`.
            ---@return integer? winid # Either the selected window ID, or `nil` to
            ---   indicate that the user cancelled / gave an invalid selection.
            window_picker = function()
                local cmdheight = vim.opt.cmdheight
                vim.opt.cmdheight = 1

                local winid = require("winshift.lib").pick_window({
                    -- A string of chars used as identifiers by the window picker.
                    picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                    filter_rules = {
                        -- This table allows you to indicate to the window picker that a window
                        -- should be ignored if its buffer matches any of the following criteria.
                        cur_win = true, -- Filter out the current window
                        floats = true,  -- Filter out floating windows
                        filetype = {},  -- List of ignored file types
                        buftype = {},   -- List of ignored buftypes
                        bufname = {},   -- List of vim regex patterns matching ignored buffer names
                    },
                    ---A function used to filter the list of selectable windows.
                    ---@param winids integer[] # The list of selectable window IDs.
                    ---@return integer[] filtered # The filtered list of window IDs.
                    filter_func = nil,
                })

                vim.opt.cmdheight = cmdheight

                return winid
            end,
        },
    },
}
