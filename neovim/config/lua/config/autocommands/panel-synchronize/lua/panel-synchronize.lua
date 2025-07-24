local M = {}

local auto_closed_panels = {}
local opened_panels = {}

M.close = function()
    local filetype = require("utils.filetype")
    local utils = require("utils")

    local panels = {}
    local floating_wins = {}
    local wins = vim.api.nvim_tabpage_list_wins(0)

    for _, win in ipairs(wins) do
        if not vim.api.nvim_win_is_valid(win) then
            goto continue
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        local is_panel_filetype, info = filetype.get_panel_filetype_info(ft)
        if is_panel_filetype then
            panels[#panels + 1] = {
                win = win,
                func = info,
            }
        end

        if vim.api.nvim_win_get_config(win).relative ~= "" then
            floating_wins[#floating_wins + 1] = win
        end

        ::continue::
    end

    -- 当关闭最后一个主编辑区域的 buf 时，自动关闭 panel
    if #wins - #floating_wins - #panels == 1 then
        for _, panel in ipairs(panels) do
            local close = panel.func.close
            if type(close) == "function" then
                close()
            elseif close then
                vim.api.nvim_win_close(panel.win, true)
            end
        end

        utils.table_clear(auto_closed_panels)
        auto_closed_panels = panels

        vim.schedule(function() vim.cmd.quit() end)
    else
        vim.cmd.quit()
    end
end

M.setup = function(opts)
    -- 跨 tab 同步 panel 的打开状态
    local synchronize_panel_status_across_tabs = vim.api.nvim_create_augroup("SynchronizePanelStatusAcrossTabs", { clear = true })
    vim.api.nvim_create_autocmd("TabLeave", {
        callback = function()
            if #auto_closed_panels > 0 then
                return
            end

            local filetype = require("utils.filetype")
            local utils = require("utils")

            utils.table_clear(opened_panels)

            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if not vim.api.nvim_win_is_valid(win) then
                    goto continue
                end

                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                local is_panel_filetype, info = filetype.get_panel_filetype_info(ft)
                if is_panel_filetype then
                    local close = info.close
                    if type(close) == "function" then
                        close()
                    elseif close then
                        vim.api.nvim_win_close(win, true)
                    end

                    opened_panels[#opened_panels + 1] = {
                        win = win,
                        func = info,
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
            local filetype = require("utils.filetype")
            local utils = require("utils")

            local panels
            if #auto_closed_panels > 0 then
                panels = auto_closed_panels
            else
                panels = opened_panels
            end

            local open_tasks = {}
            for _, panel in ipairs(panels) do
                local open_func = panel.func.open
                if type(open_func) == "function" then
                    open_tasks[#open_tasks + 1] = open_func
                end
            end
            utils.table_clear(panels)

            if #open_tasks > 0 then
                vim.schedule(function()
                    for _, task in ipairs(open_tasks) do
                        task()
                    end
                    utils.defer_fn_with_condition(function() filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1) end)
                end)
            end
        end,
        desc = "Restore panel status",
        group = synchronize_panel_status_across_tabs,
    })
end

return M
