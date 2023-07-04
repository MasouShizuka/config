local variables = require("config.variables")

return {
    {
        "folke/edgy.nvim",
        enabled = not variables.is_vscode,
        init = function()
            vim.opt.laststatus = 3
            vim.opt.splitkeep = "screen"
        end,
        keys = {
            {
                variables.keymap["<c-1>"],
                function()
                    if not variables.toggle_filetype(variables.toggle_filetype_list1) then
                        require("edgy").open("left")
                    end
                end,
                desc = "Focus left panel",
                mode = "n",
            },
            { variables.keymap["<c-2>"], function() require("edgy").goto_main() end, desc = "Focus editor", mode = "n" },
            {
                variables.keymap["<c-3>"],
                function()
                    local count = vim.v.count
                    if count > 0 then
                        vim.api.nvim_command(tostring(count) .. "ToggleTerm")
                        return
                    end
                    if not variables.toggle_filetype(variables.toggle_filetype_list2) then
                        require("edgy").open("bottom")
                    end
                end,
                desc = "Focus bottom panel",
                mode = "n",
            },
            {
                variables.keymap["<c-4>"],
                function()
                    if not variables.toggle_filetype(variables.toggle_filetype_list3) then
                        require("edgy").open("right")
                    end
                end,
                desc = "Focus right panel",
                mode = "n",
            },
        },
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
                    ft = "DiffviewFiles",
                    size = { width = 0.2 },
                },
                {
                    ft = "DiffviewFileHistory",
                    size = { width = 0.2 },
                },
                {
                    ft = "NvimTree",
                    size = { width = 0.2 },
                    pinned = true,
                    open = function() require("nvim-tree.api").tree.open() end,
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
            keys = {
                -- close window
                ["q"] = function(win)
                    win:close()
                end,
                -- hide window
                ["<c-q>"] = function(win)
                    win:hide()
                end,
                -- close sidebar
                ["Q"] = function(win)
                    win.view.edgebar:close()
                end,
                -- next open window
                ["]w"] = false,
                ["<c-j>"] = function(win)
                    win:next({ visible = true, focus = true })
                end,
                -- previous open window
                ["[w"] = false,
                ["<c-k>"] = function(win)
                    win:prev({ visible = true, focus = true })
                end,
                -- next loaded window
                ["]W"] = function(win)
                    win:next({ pinned = false, focus = true })
                end,
                -- prev loaded window
                ["[W"] = function(win)
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
