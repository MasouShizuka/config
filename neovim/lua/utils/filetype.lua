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
    "edgy",
    "fidget",
    "minimap",
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
    "edgy",
    "fidget",
    "help",
    "minimap",
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
    "edgy",
    "fidget",
    "help",
    "neo-tree",
    "minimap",
    "NvimTree",
    "nvim-docs-view",
    "toggleterm",
    "Trouble",
}

M.skip_filetype = function(skip_filetype_list, step)
    step = step or -1

    local curr_winnr = vim.fn.winnr()
    local win_count = vim.fn.winnr("$")

    local winnr = curr_winnr
    while true do
        winnr = winnr + step
        if winnr <= 0 then
            winnr = win_count
        elseif winnr > win_count then
            winnr = 1
        end

        if winnr == curr_winnr then
            break
        end

        local win = vim.fn.win_getid(winnr)
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if not vim.tbl_contains(skip_filetype_list, ft) then
            vim.api.nvim_set_current_win(win)
            break
        end
    end
end

-- toggle left panel
M.toggle_filetype_list_of_left = {
    ["aerial"] = {
        open = function() vim.api.nvim_command("AerialOpen") end,
        close = function() vim.api.nvim_command("AerialClose") end,
    },
    ["dapui_scopes"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["dapui_breakpoints"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["dapui_stacks"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["dapui_watches"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["DiffviewFiles"] = {
        open = function() vim.api.nvim_command("DiffviewOpen") end,
        close = function() vim.api.nvim_command("DiffviewClose") end,
    },
    ["DiffviewFileHistory"] = {
        open = function() vim.api.nvim_command("DiffviewOpen") end,
        close = function() vim.api.nvim_command("DiffviewClose") end,
    },
    ["neo-tree"] = {
        open = function()
            require("neo-tree.sources.manager").close_all()
            require("neo-tree.command").execute({ dir = vim.fn.getcwd() })
        end,
        close = function() require("neo-tree.command").execute({ action = "close" }) end,
    },
    ["NvimTree"] = {
        open = function() require("nvim-tree.api").tree.open() end,
        close = function() require("nvim-tree.api").tree.close() end,
    },
}
-- toggle bottom panel
M.toggle_filetype_list_of_bottom = {
    ["dap-repl"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["dapui_console"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["qf"] = {
        open = function() vim.api.nvim_command("copen") end,
        close = function() vim.api.nvim_command("cclose") end,
    },
    ["toggleterm"] = {
        open = function() vim.api.nvim_command("ToggleTerm") end,
        close = function() vim.api.nvim_command("ToggleTerm") end,
    },
    ["Trouble"] = {
        open = function() vim.api.nvim_command("Trouble") end,
        close = function() vim.api.nvim_command("TroubleClose") end,
    },
}
-- toggle right panel
M.toggle_filetype_list_of_right = {
    ["help"] = {
        open = false,
        close = false,
    },
    ["nvim-docs-view"] = {
        open = function() vim.api.nvim_command("DocsViewToggle") end,
        close = function() vim.api.nvim_command("DocsViewToggle") end,
    },
}
M.toggle_filetype_lists = {
    left = M.toggle_filetype_list_of_left,
    bottom = M.toggle_filetype_list_of_bottom,
    right = M.toggle_filetype_list_of_right,
}

M.is_toggle_filetype = function(filetype, toggle_filetype_list)
    local is_toggle_filetype, func

    if toggle_filetype_list then
        func = toggle_filetype_list[filetype]
        if func ~= nil then
            is_toggle_filetype = true
        end
    else
        for _, toggle_filetype_list in pairs(M.toggle_filetype_lists) do
            func = toggle_filetype_list[filetype]
            if func ~= nil then
                is_toggle_filetype = true
                break
            end
        end
    end

    return is_toggle_filetype, func
end

M.is_in_toggle_filetype_list = function(filetype, toggle_filetype_list)
    local is_in_toggle_filetype_list, _ = M.is_toggle_filetype(filetype, toggle_filetype_list)
    return is_in_toggle_filetype_list
end

M.is_toggle_filetype_focused = function(toggle_filetype_list)
    local ok, func = M.is_toggle_filetype(vim.bo.filetype, toggle_filetype_list)
    local close_func
    if ok then
        close_func = func.close
        if type(close_func) ~= "function" then
            local win = vim.api.nvim_get_current_win()
            close_func = function()
                vim.api.nvim_win_close(win, true)
            end
        end
    end

    return ok, close_func
end

M.is_toggle_filetype_opened = function(toggle_filetype_list)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not vim.api.nvim_win_is_valid(win) then
            goto continue
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if M.is_in_toggle_filetype_list(ft, toggle_filetype_list) then
            return true, win
        end

        ::continue::
    end

    return false, nil
end

M.toggle_filetype = function(toggle_filetype_list)
    local is_focused, func = M.is_toggle_filetype_focused(toggle_filetype_list)
    if is_focused then
        func.close()
        return true
    end

    local is_opened, win = M.is_toggle_filetype_opened(toggle_filetype_list)
    if is_opened then
        vim.api.nvim_set_current_win(win)
        return true
    end

    return false
end

return M
