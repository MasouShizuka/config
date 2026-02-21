local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        "JuanZoran/Trans.nvim",
        build = function()
            require("Trans").install()
        end,
        cmd = {
            "Translate",
            "TransPlay",
            "TranslateInput",
            "TransToggle",
        },
        cond = not environment.is_vscode,
        config = function(_, opts)
            local Trans = require("Trans")
            Trans.setup(opts)

            if require("utils").is_available("snacks.nvim") then
                local trans_win
                vim.api.nvim_create_user_command("TransToggle", function()
                    if trans_win ~= nil then
                        trans_win:destroy()
                        trans_win = nil
                        return
                    end

                    trans_win = require("snacks").win({
                        width = 0.3,
                        position = "right",
                        enter = false,
                        wo = {
                            wrap = true,
                        },
                        bo = {
                            ft = "trans-view",
                        },
                    })

                    trans_win:on({ "CursorHold", "CursorHoldI" }, function()
                        if require("utils.filetype").is_panel_filetype(vim.bo.filetype) then
                            return
                        end

                        local buf = trans_win.buf

                        local trans_opts = {}
                        trans_opts.mode = trans_opts.mode or vim.fn.mode()
                        trans_opts.str = Trans.util.get_str(trans_opts.mode)
                        local str = trans_opts.str
                        if not str or str == "" then return end

                        local data = Trans.data.new(trans_opts)
                        Trans.backend.offline.query(data)
                        if not data.result.offline then
                            return
                        end

                        local result, name = data:get_available_result()
                        if not result then
                            return
                        end

                        data.frontend.buffer.bufnr = buf

                        vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
                        vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
                        data.frontend:load(result, name, data.frontend.opts.order[name])
                        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
                    end)
                end, { desc = "Toggle trans-view" })
            end
        end,
        dependencies = {
            {
                "kkharji/sqlite.lua",
                config = function(_, opts)
                    vim.g.sqlite_clib_path = "sqlite3.dll"
                    if environment.is_windows then
                        vim.g.sqlite_clib_path = path.sqlite_path
                    end
                end,
            },
        },
        opts = {
            debug = false,
            frontend = {
                default = {
                    ---@type {open: string | boolean, close: string | boolean, interval: integer} Hover Window Animation
                    animation = {
                        open = false, -- 'fold', 'slid'
                        close = false,
                    },
                },
                hover = {
                    ---@type string[] auto close events
                    auto_close_events = false,
                    ---@type table<string, string[]> order to display translate result
                    order = {
                        offline = {
                            "title",
                            "translation",
                            "exchange",
                            "pos",
                            "tag",
                            "definition",
                        },
                    },
                },
            },
        },
    },
}
