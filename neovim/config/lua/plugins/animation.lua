local environment = require("utils.environment")

return {
    {
        "y3owk1n/undo-glow.nvim",
        cond = not environment.is_vscode,
        init = function()
            local utils = require("utils")
            utils.create_once_autocmd("User", {
                callback = function()
                    vim.api.nvim_create_autocmd("TextYankPost", {
                        callback = function()
                            require("undo-glow").yank()
                        end,
                        desc = "Highlight when yanking (copying) text",
                    })

                    -- This only handles neovim instance and do not highlight when switching panes in tmux
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        callback = function()
                            require("undo-glow").cursor_moved({
                                animation = {
                                    animation_type = "slide",
                                },
                            })
                        end,
                        desc = "Highlight when cursor moved significantly",
                    })

                    vim.api.nvim_create_autocmd("CmdLineLeave", {
                        callback = function()
                            require("undo-glow").search_cmd({
                                animation = {
                                    animation_type = "fade",
                                },
                            })
                        end,
                        desc = "Highlight when search cmdline leave",
                        pattern = { "/", "?" },
                    })
                end,
                desc = "undo-glow init",
                pattern = "IceLoad",
            })
        end,
        keys = function()
            local keys = {
                { "u",     function() require("undo-glow").undo() end, desc = "Undo with highlight", mode = "n" },
                { "<c-r>", function() require("undo-glow").redo() end, desc = "Redo with highlight", mode = "n" },
            }

            if require("utils").is_available("yanky.nvim") then
                local yanky_keys = {
                    {
                        "y",
                        function()
                            return require("undo-glow").yanky_put("YankyYank")
                        end,
                        desc = "Yank",
                        expr = true,
                        mode = { "n", "x" },
                    },
                    {
                        "p",
                        function()
                            return require("undo-glow").yanky_put("YankyPutAfter")
                        end,
                        desc = "Put yanked text after cursor",
                        expr = true,
                        mode = { "n", "x" },
                    },
                    {
                        "P",
                        function()
                            return require("undo-glow").yanky_put("YankyPutBefore")
                        end,
                        desc = "Put yanked text before cursor",
                        expr = true,
                        mode = { "n", "x" },
                    },
                    {
                        "<leader>p",
                        function()
                            return '"+' .. require("undo-glow").yanky_put("YankyPutAfter")
                        end,
                        desc = "Put yanked text after cursor",
                        expr = true,
                        mode = { "n", "x" },
                    },
                    {
                        "<leader>P",
                        function()
                            return '"+' .. require("undo-glow").yanky_put("YankyPutBefore")
                        end,
                        desc = "Put yanked text before cursor",
                        expr = true,
                        mode = { "n", "x" },
                    },
                }
                keys = require("utils").table_concat(keys, yanky_keys)
            end

            return keys
        end,
        opts = {
            animation = {
                enabled = true,       -- whether to turn on or off for animation
                duration = 1000,      -- in ms
                window_scoped = true, -- this uses an experimental extmark options (it might not work depends on your version of neovim)
            },
        },
    },
}
