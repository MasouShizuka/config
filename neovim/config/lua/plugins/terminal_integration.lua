local environment = require("utils.environment")
local utils = require("utils")

return {
    {
        "akinsho/toggleterm.nvim",
        cmd = {
            "ToggleTerm",
            "ToggleTermToggleAll",
            "TermExec",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualLines",
            "ToggleTermSendVisualSelection",
            "ToggleTermSetName",
        },
        enabled = not environment.is_vscode,
        init = function()
            local list = {}

            local function toggle_func(name, cmd)
                if cmd == nil then
                    cmd = name
                end

                if list[name] == nil then
                    list[name] = require("toggleterm.terminal").Terminal:new({
                        cmd = cmd,
                        hidden = true,
                        direction = "float",
                        -- function to run on opening the terminal
                        on_open = function(term)
                            vim.cmd.startinsert({ bang = true })
                            vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, silent = true })

                            -- 禁用 toggleterm 的 esc 映射
                            vim.keymap.set("t", "<esc>", function()
                                local key = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
                                vim.api.nvim_feedkeys(key, "n", false)
                            end, { buffer = term.bufnr, silent = true })

                            -- 禁用 cellwidth 设置
                            if utils.is_available("cellwidths.nvim") and package.loaded["cellwidths"] then
                                vim.api.nvim_command("CellWidthsLoad empty")
                            end
                        end,
                        -- function to run on closing the terminal
                        on_close = function(term)
                            vim.cmd.startinsert({ bang = true })

                            -- 恢复 cellwidth 设置
                            if utils.is_available("cellwidths.nvim") and package.loaded["cellwidths"] then
                                vim.api.nvim_command("CellWidthsLoad default")
                            end
                        end,
                    })
                end

                list[name]:toggle()
            end

            local is_wk_available, wk = pcall(require, "which-key")
            if is_wk_available then
                wk.add({
                    { "<leader>T", group = "command line tool", mode = "n" },
                })
            end
            vim.keymap.set("n", "<leader>Tl", function() toggle_func("lazygit") end, { desc = "Open lazygit", silent = true })
            vim.keymap.set("n", "<leader>Ty", function() toggle_func("yazi", string.format([[yazi "%s"]], vim.fn.getcwd())) end, { desc = "Open yazi", silent = true })
        end,
        opts = {
            -- size can be a number or function which is passed the current terminal
            size = function(term)
                if term.direction == "horizontal" then
                    return math.floor((vim.o.lines - vim.o.cmdheight) * 0.3)
                elseif term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.3)
                end
            end,
            -- function to run when the terminal is first created
            on_create = function(t)
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.foldcolumn = "0"
                vim.opt_local.signcolumn = "no"
            end,
            persist_size = false,
            direction = "horizontal",
            -- This field is only relevant if direction is set to 'float'
            float_opts = {
                -- The border key is *almost* the same as 'nvim_open_win'
                -- see :h nvim_open_win for details on borders however
                -- the 'curved' border is a custom border type
                -- not natively supported but implemented in this plugin.
                border = "curved",
                height = function()
                    return math.floor((vim.o.lines - vim.o.cmdheight) * 0.9)
                end,
                width = function()
                    return math.floor(vim.o.columns * 0.9)
                end,
            },
        },
    },
}
