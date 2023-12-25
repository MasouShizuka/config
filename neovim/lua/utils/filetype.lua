local M = {}

M.text_filetype = {
    "markdown",
    "plaintex",
    "tex",
    "text",
}

-- plugins skip these
M.skip_filetype_list = {
    "aerial",
    "alpha",
    "dashboard",
    "DiffviewFiles",
    "DiffviewFileHistory",
    "neo-tree",
    "NvimTree",
    "notify",
    "toggleterm",
    "Trouble",
}
-- skip when <c-2>
M.skip_filetype_list_to_main = {
    "aerial",
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "DiffviewFiles",
    "DiffviewFileHistory",
    "help",
    "neo-tree",
    "NvimTree",
    "notify",
    "nvim-docs-view",
    "toggleterm",
    "Trouble",
}
-- skip when <c-j>, <c-k>
M.skip_filetype_list_of_panel = {
    "aerial",
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "DiffviewFiles",
    "DiffviewFileHistory",
    "help",
    "neo-tree",
    "NvimTree",
    "nvim-docs-view",
    "toggleterm",
    "Trouble",
}

M.skip_filetype = function(skip_filetype_list, wincmd)
    wincmd = wincmd or "W"

    local ft = vim.bo.filetype
    local max_skip = 20
    while vim.tbl_contains(skip_filetype_list, ft) and max_skip > 0 do
        vim.cmd.wincmd(wincmd)
        ft = vim.bo.filetype
        max_skip = max_skip - 1
    end
end

-- toggle left panel
M.toggle_filetype_list_of_left = {
    ["aerial"] = function() vim.api.nvim_command("AerialClose") end,
    ["dapui_scopes"] = false,
    ["dapui_breakpoints"] = false,
    ["dapui_stacks"] = false,
    ["dapui_watches"] = false,
    ["DiffviewFiles"] = function() vim.api.nvim_command("DiffviewClose") end,
    ["DiffviewFileHistory"] = function() vim.api.nvim_command("DiffviewClose") end,
    ["neo-tree"] = function() require("neo-tree.command").execute({ action = "close" }) end,
    ["NvimTree"] = function() require("nvim-tree.api").tree.close() end,
}
-- toggle bottom panel
M.toggle_filetype_list_of_bottom = {
    ["dap-repl"] = false,
    ["dapui_console"] = false,
    ["qf"] = false,
    ["toggleterm"] = function() vim.api.nvim_command("ToggleTerm") end,
    ["Trouble"] = function() vim.api.nvim_command("TroubleClose") end,
}
-- toggle right panel
M.toggle_filetype_list_of_right = {
    ["help"] = false,
    ["nvim-docs-view"] = function() vim.api.nvim_command("DocsViewToggle") end,
}

M.is_toggle_filetype = function(filetype, toggle_filetype_list)
    if toggle_filetype_list then
        for toggle_filetype, close_function in pairs(toggle_filetype_list) do
            if filetype == toggle_filetype then
                return true, close_function
            end
        end
    else
        for toggle_filetype, close_function in pairs(M.toggle_filetype_list_of_left) do
            if filetype == toggle_filetype then
                return true, close_function
            end
        end

        for toggle_filetype, close_function in pairs(M.toggle_filetype_list_of_bottom) do
            if filetype == toggle_filetype then
                return true, close_function
            end
        end

        for toggle_filetype, close_function in pairs(M.toggle_filetype_list_of_right) do
            if filetype == toggle_filetype then
                return true, close_function
            end
        end
    end

    return false, nil
end

M.is_in_toggle_filetype_list = function(filetype, toggle_filetype_list)
    local is_in_toggle_filetype_list, _ = M.is_toggle_filetype(filetype, toggle_filetype_list)
    if is_in_toggle_filetype_list then
        return true
    end

    return false
end

M.is_toggle_filetype_focused = function(toggle_filetype_list, close)
    local ok, close_function = M.is_toggle_filetype(vim.bo.filetype, toggle_filetype_list)
    if ok then
        if type(close_function) ~= "function" then
            close_function = function()
                vim.api.nvim_win_close(vim.api.nvim_get_current_win(), false)
            end
        end

        if close then
            close_function()
        end

        return true, close_function
    end

    return false, nil
end

M.is_toggle_filetype_opened = function(toggle_filetype_list, focus)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })

        local ok, _ = M.is_toggle_filetype(ft, toggle_filetype_list)
        if ok then
            if focus then
                vim.api.nvim_set_current_win(win)
            end

            return true, win
        end
    end

    return false, nil
end

M.toggle_filetype = function(toggle_filetype_list)
    local is_focused, _ = M.is_toggle_filetype_focused(toggle_filetype_list, true)
    if is_focused then
        return true
    end

    local is_opened, _ = M.is_toggle_filetype_opened(toggle_filetype_list, true)
    if is_opened then
        return true
    end

    return false
end

return M
