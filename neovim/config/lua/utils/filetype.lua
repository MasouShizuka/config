local M = {}

M.tex_filetype_list = {
    "markdown",
    "plaintex",
    "tex",
}

M.text_filetype_list = {
    "text",
}

--- Plugins skip these
M.skip_filetype_list = {
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "edgy",
    "fencview",
    "lazy",
    "mason",
    "minimap",
    "noice",
    "OverseerForm",
    "OverseerList",
    "OverseerOutput",
    "snacks_dashboard",
    "snacks_explorer_input",
    "snacks_explorer_list",
    "snacks_notif",
    "snacks_picker_preview",
    "snacks_terminal",
    "Trans",
    "trans-view",
    "trouble",
}
--- Skip when <c-2>
M.skip_filetype_list_to_main = {
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "edgy",
    "fencview",
    "minimap",
    "noice",
    "OverseerForm",
    "OverseerList",
    "OverseerOutput",
    "qf",
    "snacks_explorer_input",
    "snacks_explorer_list",
    "snacks_layout_box",
    "snacks_notif",
    "snacks_terminal",
    "Trans",
    "trans-view",
    "trouble",
}
--- Skip when <c-j>, <c-k>
M.skip_filetype_list_of_panel = {
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "edgy",
    "fencview",
    "minimap",
    "noice",
    "OverseerForm",
    "OverseerList",
    "OverseerOutput",
    "qf",
    "snacks_explorer_input",
    "snacks_explorer_list",
    "snacks_layout_box",
    "snacks_terminal",
    "Trans",
    "trans-view",
    "trouble",
}

--- Skip the win whose filetype is in the list
---@param skip_filetype_list string[]
---@param step? integer
M.skip_filetype = function(skip_filetype_list, step)
    step = step or -1

    local nvim_treesitter_context_available = require("utils").is_available("nvim-treesitter-context")

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
        -- 防止跳转到 nvim-treesitter-context 的窗口上
        if
            nvim_treesitter_context_available
            and (vim.w[win].treesitter_context or vim.w[win].treesitter_context_line_number)
        then
            goto continue
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if not vim.tbl_contains(skip_filetype_list, ft) then
            vim.api.nvim_set_current_win(win)
            break
        end

        ::continue::
    end
end

---@class panel_filetype_info
---@field close function|boolean
---@field open? function
---@field pinned? boolean

---@alias panel_filetype_list table<string, panel_filetype_info>

---@type panel_filetype_list
M.left_panel_filetype_list = {
    ["dapui_scopes"] = {
        close = function() require("dapui").close() end,
        open = function() require("dapui").open() end,
    },
    ["dapui_breakpoints"] = {
        close = function() require("dapui").close() end,
        open = function() require("dapui").open() end,
    },
    ["dapui_stacks"] = {
        close = function() require("dapui").close() end,
        open = function() require("dapui").open() end,
    },
    ["dapui_watches"] = {
        close = function() require("dapui").close() end,
        open = function() require("dapui").open() end,
    },
    ["edgy"] = {
        close = true,
    },
    ["snacks_explorer_input"] = {
        close = function() require("snacks").explorer() end,
        open = function() require("snacks").explorer() end,
        pinned = true,
    },
    ["snacks_explorer_list"] = {
        close = false,
    },
}
---@type panel_filetype_list
M.bottom_panel_filetype_list = {
    ["dap-repl"] = {
        close = function() require("dapui").close() end,
        open = function() require("dapui").open() end,
    },
    ["dapui_console"] = {
        close = function() require("dapui").close() end,
        open = function() require("dapui").open() end,
    },
    ["edgy"] = {
        close = true,
    },
    ["qf"] = {
        close = function() vim.api.nvim_command("cclose") end,
        open = function() vim.api.nvim_command("copen") end,
    },
    ["OverseerOutput"] = {
        close = true,
    },
    ["snacks_terminal"] = {
        close = function() require("snacks").terminal() end,
        open = function() require("snacks").terminal() end,
        pinned = true,
    },
    ["trouble"] = {
        close = function() require("trouble").close() end,
        open = function() require("trouble").open({ mode = "last" }) end,
    },
}
---@type panel_filetype_list
M.right_panel_filetype_list = {
    ["edgy"] = {
        close = true,
    },
    ["fencview"] = {
        close = function() vim.api.nvim_command("FencView") end,
        open = function() vim.api.nvim_command("FencView") end,
    },
    ["OverseerList"] = {
        close = function() vim.api.nvim_command("OverseerClose") end,
        open = function() vim.api.nvim_command("OverseerOpen") end,
    },
    ["trans-view"] = {
        close = function() vim.api.nvim_command("TransToggle") end,
        open = function() vim.api.nvim_command("TransToggle") end,
        pinned = true,
    },
    ["trouble"] = {
        close = function() require("trouble").close() end,
        open = function() require("trouble").open({ mode = "last" }) end,
    },
}
---@type table<string, panel_filetype_list>
M.panel_filetype_lists = {
    left = M.left_panel_filetype_list,
    bottom = M.bottom_panel_filetype_list,
    right = M.right_panel_filetype_list,
}

--- Get the ft's panel filetype info
---@param ft string
---@param panel_filetype_list? panel_filetype_list
---@return boolean, panel_filetype_info|nil
M.get_panel_filetype_info = function(ft, panel_filetype_list)
    local is_panel_filetype, info

    local lists
    if panel_filetype_list then
        lists = { panel_filetype_list }
    else
        lists = M.panel_filetype_lists
    end

    for _, list in pairs(lists) do
        info = list[ft]
        if info ~= nil then
            is_panel_filetype = true
            break
        end
    end

    return is_panel_filetype, info
end

--- Check if the filetype is the panel filetype
---@param filetype string
---@param panel_filetype_list? panel_filetype_list
---@return boolean
M.is_panel_filetype = function(filetype, panel_filetype_list)
    local is_panel_filetype, _ = M.get_panel_filetype_info(filetype, panel_filetype_list)
    return is_panel_filetype
end

--- Get the focused win's panel filetype info
---@param panel_filetype_list? panel_filetype_list
---@return boolean, panel_filetype_info|nil
M.get_focused_panel_filetype_info = function(panel_filetype_list)
    local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
    local ok, info = M.get_panel_filetype_info(ft, panel_filetype_list)
    if ok and info then
        local close = info.close
        if type(close) ~= "function" then
            info = vim.deepcopy(info)
            if close then
                local win = vim.api.nvim_get_current_win()
                info.close = function() vim.api.nvim_win_close(win, true) end
            else
                info.close = function() end
            end
        end
    end

    return ok, info
end

--- Get all opened wins of panel filetype in current tabpage
---@param panel_filetype_list? panel_filetype_list
---@return integer[]
M.get_opened_panel_filetype_wins = function(panel_filetype_list)
    local opened = {}

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not vim.api.nvim_win_is_valid(win) then
            goto continue
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if require("utils").is_available("edgy.nvim") and ft == "edgy" then
            goto continue
        end

        if M.is_panel_filetype(ft, panel_filetype_list) then
            opened[#opened + 1] = win
        end

        ::continue::
    end

    return opened
end

--- Toggle panel, close if focused, focus if opened and open if no wins in the pos
---@param pos string
M.toggle_panel = function(pos)
    local panel_filetype_list = M.panel_filetype_lists[pos]

    local is_focused, info = M.get_focused_panel_filetype_info(panel_filetype_list)
    if is_focused and info then
        info.close()
        return
    end

    local opened = M.get_opened_panel_filetype_wins(panel_filetype_list)
    if #opened > 0 then
        vim.api.nvim_set_current_win(opened[1])
        return
    end

    for _, info in pairs(panel_filetype_list) do
        if info.pinned then
            if type(info.open) == "function" then
                info.open()
            end
        end
    end
end

return M
