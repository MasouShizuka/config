local variables = require("config.variables")

if not variables.is_vscode then
    -- 使用宏时显示信息
    local show_recording_info = vim.api.nvim_create_augroup("show_recording_info", { clear = true })
    vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function()
            vim.api.nvim_set_option_value("cmdheight", 1, {})
        end,
        desc = "Set cmdheight=1 when start recording",
        group = show_recording_info,
        pattern = "*",
    })
    vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
            vim.api.nvim_set_option_value("cmdheight", 0, {})
        end,
        desc = "Set cmdheight=0 when finished recording",
        group = show_recording_info,
        pattern = "*",
    })

    -- 关闭 tab 后转到左边的 tab
    local prev_last_tabpage = vim.fn.tabpagenr("$")
    local prev_tabpage = vim.fn.tabpagenr()
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local last_tabpage = vim.fn.tabpagenr("$")
            local tabpage = vim.fn.tabpagenr()
            if tabpage > 1 and prev_tabpage ~= prev_last_tabpage and last_tabpage < prev_last_tabpage then
                vim.cmd.tabprevious()
            end
            prev_last_tabpage = last_tabpage
            prev_tabpage = tabpage
        end,
        desc = "Go to left tab after closing tab",
        group = vim.api.nvim_create_augroup("go_to_left_tab_after_closing_tab", { clear = true }),
        pattern = "*",
    })
end
