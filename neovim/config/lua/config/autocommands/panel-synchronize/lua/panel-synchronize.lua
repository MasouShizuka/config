local filetype = require("utils.filetype")
local utils = require("utils")

local M = {}

local auto_closed_panels = {}
local opened_panels = {}

M.setup = function(opts)
    -- 当关闭最后一个主编辑区域的 buf 时，自动关闭 panel
    vim.api.nvim_create_autocmd("QuitPre", {
        callback = function(args)
            local buf = args.buf
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if filetype.is_panel_filetype(ft) then
                return
            end

            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                return
            end

            local panels = {}
            local floating_wins = {}
            local wins = vim.api.nvim_tabpage_list_wins(0)

            for _, win in ipairs(wins) do
                if not vim.api.nvim_win_is_valid(win) then
                    goto continue
                end

                buf = vim.api.nvim_win_get_buf(win)
                ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                local is_panel_filetype, func = filetype.get_panel_filetype_func(ft)
                if is_panel_filetype then
                    panels[#panels + 1] = {
                        win = win,
                        func = func,
                    }
                end

                if vim.api.nvim_win_get_config(win).relative ~= "" then
                    floating_wins[#floating_wins + 1] = win
                end

                ::continue::
            end

            if #wins - #floating_wins - #panels == 1 then
                for _, panel in ipairs(panels) do
                    local close_func = panel.func.close
                    if type(close_func) == "function" then
                        close_func()
                    else
                        vim.api.nvim_win_close(panel.win, true)
                    end
                end

                utils.table_clear(auto_closed_panels)
                auto_closed_panels = panels
            end
        end,
        desc = "Auto close panel",
        group = vim.api.nvim_create_augroup("PanelAutoClose", { clear = true }),
    })


    -- 跨 tab 同步 panel 的打开状态
    local synchronize_panel_status_across_tabs = vim.api.nvim_create_augroup("SynchronizePanelStatusAcrossTabs", { clear = true })
    vim.api.nvim_create_autocmd("TabLeave", {
        callback = function()
            local is_opening_tab = vim.g.is_opening_tab or false
            if is_opening_tab then
                return
            end

            if #auto_closed_panels > 0 then
                return
            end

            utils.table_clear(opened_panels)

            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if not vim.api.nvim_win_is_valid(win) then
                    goto continue
                end

                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                local is_panel_filetype, func = filetype.get_panel_filetype_func(ft)
                if is_panel_filetype then
                    local close_func = func.close
                    if type(close_func) == "function" then
                        close_func()
                    else
                        vim.api.nvim_win_close(win, true)
                    end

                    opened_panels[#opened_panels + 1] = {
                        win = win,
                        func = func,
                    }
                end

                ::continue::
            end
        end,
        desc = "Remember panel status",
        group = synchronize_panel_status_across_tabs,
    })
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local is_opening_tab = vim.g.is_opening_tab or false
            if is_opening_tab then
                return
            end

            local function reopen(panels)
                local open_task = {}

                for _, panel in ipairs(panels) do
                    local open_func = panel.func.open
                    if type(open_func) == "function" then
                        open_task[#open_task + 1] = open_func
                    end
                end

                utils.table_clear(panels)

                return open_task
            end

            local open_task
            if #auto_closed_panels > 0 then
                open_task = reopen(auto_closed_panels)
            else
                open_task = reopen(opened_panels)
            end

            if #open_task > 0 then
                vim.schedule(function()
                    for _, task in ipairs(open_task) do
                        task()
                    end
                    utils.defer(function() filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1) end, 100, false)
                end)
            end
        end,
        desc = "Restore panel status",
        group = synchronize_panel_status_across_tabs,
    })
end

return M
