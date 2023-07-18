local variables = require("config.variables")

return {
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

            local function toggle(pos, toggle_filetype_list)
                local is_focused, close_function = variables.is_toggle_filetype_focused(toggle_filetype_list, false)
                if is_focused then
                    if not close_all_wins(pos, toggle_filetype_list) then
                        close_function()
                    end
                    require("edgy").close(pos)

                    return
                end

                local is_opened, win = variables.is_toggle_filetype_opened(toggle_filetype_list, false)
                if is_opened then
                    if not focus_nth_win(pos, 1) then
                        vim.api.nvim_set_current_win(win)
                    end
                    return
                end

                require("edgy").open(pos)
            end

            vim.keymap.set("n", variables.keymap["<c-1>"], function()
                toggle("left", variables.toggle_filetype_list1)
            end, { desc = "Focus left panel", silent = true })
            vim.keymap.set("n", variables.keymap["<c-2>"], function()
                for _, edgebar in pairs(require("edgy.config").layout) do
                    if #edgebar.wins > 0 then
                        require("edgy").goto_main()
                        return
                    end
                end

                variables.skip_filetype(variables.skip_filetype_list1, "W")
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
                -- {
                --     ft = "neo-tree",
                --     filter = function(buf)
                --         return vim.b[buf].neo_tree_source == "filesystem"
                --     end,
                --     title = "Neo-Tree",
                --     size = { width = 0.2, height = 0.7 },
                --     pinned = true,
                --     open = function()
                --         require("neo-tree.sources.manager").close_all()
                --         require("neo-tree.command").execute({ dir = vim.fn.getcwd() })
                --     end,
                -- },
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
                {
                    ft = "NvimTree",
                    size = { width = 0.2, height = 0.7 },
                    pinned = true,
                    open = function() require("nvim-tree.api").tree.open() end,
                },
                {
                    ft = "aerial",
                    title = "Aerial",
                    size = { width = 0.2 },
                    pinned = true,
                    open = function() vim.api.nvim_command("AerialOpen") end,
                },
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
            exit_when_last = true,
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
}
