local environment = require("utils.environment")

return {
    {
        "folke/edgy.nvim",
        config = function(_, opts)
            local edgy = require("edgy")
            edgy.setup(opts)

            local filetype = require("utils.filetype")
            local keymap = require("utils.keymap")
            local utils = require("utils")

            local function focus_nth_win(pos, n)
                for p, edgebar in pairs(require("edgy.config").layout) do
                    if p == pos then
                        for i = n, #edgebar.wins do
                            if edgebar.wins[i].visible then
                                edgebar.wins[i]:focus()
                                return true
                            end
                        end

                        break
                    end
                end

                return false
            end

            local prev_tabpage
            local prev_win
            local function toggle(pos)
                local panel_filetype_list = filetype.panel_filetype_lists[pos]

                local is_focused, _ = filetype.get_focused_panel_filetype_info(panel_filetype_list)
                if is_focused then
                    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                        if not vim.api.nvim_win_is_valid(win) then
                            goto continue
                        end

                        local buf = vim.api.nvim_win_get_buf(win)
                        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                        local is_panel_filetype, info = filetype.get_panel_filetype_info(ft, panel_filetype_list)
                        if is_panel_filetype then
                            local close = info.close
                            if type(close) == "function" then
                                close()
                            elseif close then
                                vim.api.nvim_win_close(win, true)
                            end
                        end

                        ::continue::
                    end

                    return
                end

                local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
                if not filetype.is_panel_filetype(ft) then
                    prev_tabpage = vim.api.nvim_get_current_tabpage()
                    prev_win = vim.api.nvim_get_current_win()
                end

                local opened = filetype.get_opened_panel_filetype_wins(panel_filetype_list)
                if #opened > 0 then
                    if not focus_nth_win(pos, 1) then
                        vim.api.nvim_set_current_win(opened[1])
                    end
                else
                    edgy.open(pos)
                end
            end

            vim.keymap.set("n", keymap["<c-1>"], function() toggle("left") end, { desc = "Focus left panel", silent = true })
            vim.keymap.set("n", keymap["<c-2>"], function()
                -- for _, edgebar in pairs(require("edgy.config").layout) do
                --     if #edgebar.wins > 0 then
                --         edgy.goto_main()
                --         return
                --     end
                -- end

                if vim.api.nvim_get_current_tabpage() == prev_tabpage and prev_win then
                    vim.api.nvim_set_current_win(prev_win)
                else
                    filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1)
                end
            end, { desc = "Focus main editor", silent = true })
            vim.keymap.set("n", keymap["<c-3>"], function()
                local count = vim.v.count
                if count > 0 then
                    if utils.is_available("snacks.nvim") then
                        require("snacks").terminal()
                        return
                    end
                end

                toggle("bottom")
            end, { desc = "Focus bottom panel", silent = true })
            vim.keymap.set("n", keymap["<c-4>"], function() toggle("right") end, { desc = "Focus right panel", silent = true })
        end,
        enabled = not environment.is_vscode,
        init = function()
            -- edgy 自动激活
            local id
            id = vim.api.nvim_create_autocmd("BufNew", {
                callback = function(args)
                    vim.schedule(function()
                        if vim.api.nvim_buf_is_valid(args.buf) then
                            local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                            if require("utils.filetype").is_panel_filetype(ft) then
                                require("lazy").load({ plugins = "edgy.nvim" })
                                pcall(vim.api.nvim_del_autocmd, id)
                            end
                        end
                    end)
                end,
                desc = "Activate edgy",
            })
        end,
        keys = function()
            local keymap = require("utils.keymap")

            return {
                { keymap["<c-1>"], desc = "Focus left panel",   mode = "n" },
                { keymap["<c-2>"], desc = "Focus main editor",  mode = "n" },
                { keymap["<c-3>"], desc = "Focus bottom panel", mode = "n" },
                { keymap["<c-4>"], desc = "Focus right panel",  mode = "n" },
            }
        end,
        opts = function()
            local filetype = require("utils.filetype")
            local utils = require("utils")

            local left = {}

            local bottom = {
                {
                    ft = "qf",
                    title = "QuickFix",
                    size = { height = 0.3 },
                },
            }

            local right = {}

            if utils.is_available("config.user_commands.fencview") then
                right[#right + 1] = {
                    ft = "fencview",
                    size = { width = 0.5 },
                }
            end

            if utils.is_available("nvim-dap") then
                bottom[#bottom + 1] = {
                    ft = "dap-repl",
                    size = { height = 0.3 },
                }
            end

            if utils.is_available("nvim-dap-ui") then
                local dap_left = {
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
                }
                for _, value in ipairs(dap_left) do
                    left[#left + 1] = value
                end

                bottom[#bottom + 1] = {
                    ft = "dapui_console",
                    size = { height = 0.3 },
                }
            end

            if utils.is_available("overseer.nvim") then
                bottom[#bottom + 1] = {
                    ft = "OverseerOutput",
                    size = { height = 0.3 },
                }
                right[#right + 1] = {
                    ft = "OverseerList",
                    size = { width = 0.3 },
                }
            end

            if utils.is_available("snacks.nvim") then
                left[#left + 1] = {
                    ft = "snacks_explorer_list",
                    size = { width = 0.2 },
                }
                left[#left + 1] = {
                    ft = "snacks_explorer_input",
                    size = { width = 0.2, height = 0.1 },
                    pinned = true,
                    open = filetype.left_panel_filetype_list["snacks_explorer_input"].open,
                }
                bottom[#bottom + 1] = {
                    ft = "snacks_terminal",
                    filter = function(_buf, win)
                        return vim.w[win].snacks_win
                            and vim.w[win].snacks_win.position == "bottom"
                            and vim.w[win].snacks_win.relative == "editor"
                            and not vim.w[win].trouble_preview
                    end,
                    -- title = "%{b:snacks_terminal.id}: %{b:term_title}",
                    size = { height = 0.3 },
                    pinned = true,
                    open = filetype.bottom_panel_filetype_list["snacks_terminal"].open,
                }
            end

            if utils.is_available("Trans.nvim") then
                right[#right + 1] = {
                    ft = "trans-view",
                    size = { width = 0.3 },
                    pinned = true,
                    open = filetype.right_panel_filetype_list["trans-view"].open,
                }
            end

            if utils.is_available("trouble.nvim") then
                bottom[#bottom + 1] = {
                    ft = "trouble",
                    filter = function(_buf, win)
                        return vim.w[win].trouble
                            and vim.w[win].trouble.position == "bottom"
                            and vim.w[win].trouble.type == "split"
                            and vim.w[win].trouble.relative == "editor"
                            and not vim.w[win].trouble_preview
                    end,
                    size = { height = 0.3 },
                }
                right[#right + 1] = {
                    ft = "trouble",
                    filter = function(_buf, win)
                        return vim.w[win].trouble
                            and vim.w[win].trouble.position == "right"
                            and vim.w[win].trouble.type == "split"
                            and vim.w[win].trouble.relative == "editor"
                            and not vim.w[win].trouble_preview
                    end,
                    size = { width = 0.3 },
                }
            end

            return {
                left = left,
                bottom = bottom,
                right = right,
                animate = {
                    enabled = false,
                },
                -- buffer-local keymaps to be added to edgebar buffers.
                -- Existing buffer-local keymaps will never be overridden.
                -- Set to false to disable a builtin.
                ---@type table<string, fun(win:Edgy.Window)|false>
                keys = {
                    -- -- close window
                    -- ["q"] = function(win)
                    --     win:close()
                    -- end,
                    -- hide window
                    -- ["<c-q>"] = function(win)
                    --   win:hide()
                    -- end,
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
                    -- -- close sidebar
                    -- ["Q"] = function(win)
                    --     win.view.edgebar:close()
                    -- end,
                    -- -- next open window
                    -- ["]w"] = function(win)
                    --     win:next({ visible = true, focus = true })
                    -- end,
                    -- -- previous open window
                    -- ["[w"] = function(win)
                    --     win:prev({ visible = true, focus = true })
                    -- end,
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
                    -- -- reset all custom sizing
                    -- ["<c-w>="] = function(win)
                    --     win.view.edgebar:equalize()
                    -- end,
                },
            }
        end,
    },

    {
        "sindrets/winshift.nvim",
        cmd = {
            "WinShift",
        },
        enabled = not environment.is_vscode,
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
                local cmdheight = vim.api.nvim_get_option_value("cmdheight", { scope = "local" })
                vim.api.nvim_set_option_value("cmdheight", 1, { scope = "local" })

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

                vim.api.nvim_set_option_value("cmdheight", cmdheight, { scope = "local" })

                return winid
            end,
        },
    },
}
