local utils = require("utils")

local M = {}

M.tex_filetype_list = {
    "markdown",
    "plaintex",
    "tex",
}

M.text_filetype_list = {
    "text",
}

-- plugins skip these
M.skip_filetype_list = {
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "dashboard",
    "edgy",
    "lazy",
    "mason",
    "minimap",
    "noice",
    "notify",
    "nvim-docs-view",
    "NvimTree",
    "OverseerForm",
    "OverseerList",
    "OverseerOutput",
    "toggleterm",
    "Trans",
    "trans-view",
    "trouble",
}
-- skip when <c-2>
M.skip_filetype_list_to_main = {
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "edgy",
    "help",
    "minimap",
    "noice",
    "notify",
    "nvim-docs-view",
    "NvimTree",
    "OverseerForm",
    "OverseerList",
    "OverseerOutput",
    "qf",
    "toggleterm",
    "Trans",
    "trans-view",
    "trouble",
}
-- skip when <c-j>, <c-k>
M.skip_filetype_list_of_panel = {
    "dap-repl",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "edgy",
    "help",
    "minimap",
    "noice",
    "nvim-docs-view",
    "NvimTree",
    "OverseerForm",
    "OverseerList",
    "OverseerOutput",
    "qf",
    "toggleterm",
    "Trans",
    "trans-view",
    "trouble",
}

M.skip_filetype = function(skip_filetype_list, step)
    step = step or -1

    local nvim_treesitter_context_available = utils.is_available("nvim-treesitter-context")

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

M.left_panel_filetype_list = {
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
    ["edgy"] = {
        open = false,
        close = false,
    },
    ["NvimTree"] = {
        open = function() require("nvim-tree.api").tree.open() end,
        close = function() require("nvim-tree.api").tree.close() end,
    },
}
M.bottom_panel_filetype_list = {
    ["dap-repl"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["dapui_console"] = {
        open = function() require("dapui").open() end,
        close = function() require("dapui").close() end,
    },
    ["edgy"] = {
        open = false,
        close = false,
    },
    ["qf"] = {
        open = function() vim.api.nvim_command("copen") end,
        close = function() vim.api.nvim_command("cclose") end,
    },
    ["OverseerOutput"] = {
        open = false,
        close = false,
    },
    ["toggleterm"] = {
        open = function() vim.api.nvim_command("ToggleTerm") end,
        close = function() vim.api.nvim_command("ToggleTerm") end,
    },
    ["trouble"] = {
        open = function() require("trouble").open({ mode = "last" }) end,
        close = function() require("trouble").close() end,
    },
}
M.right_panel_filetype_list = {
    ["edgy"] = {
        open = false,
        close = false,
    },
    ["help"] = {
        open = false,
        close = false,
    },
    ["nvim-docs-view"] = {
        open = function() vim.api.nvim_command("DocsViewToggle") end,
        close = function() vim.api.nvim_command("DocsViewToggle") end,
    },
    ["OverseerList"] = {
        open = function() vim.api.nvim_command("OverseerOpen") end,
        close = function() vim.api.nvim_command("OverseerClose") end,
    },
    ["Trans"] = {
        open = function() vim.api.nvim_command("Translate") end,
        close = function()
            local queue = require("Trans.frontend.hover").queue
            for i = #queue, 1, -1 do
                queue[i]:destroy()
                table.remove(queue, i)
            end
            utils.table_clear(require("Trans").cache)
        end,
    },
    ["trans-view"] = {
        open = function() vim.api.nvim_command("TransToggle") end,
        close = function() vim.api.nvim_command("TransToggle") end,
    },
    ["trouble"] = {
        open = function() require("trouble").open({ mode = "last" }) end,
        close = function() require("trouble").close() end,
    },
}
M.panel_filetype_lists = {
    left = M.left_panel_filetype_list,
    bottom = M.bottom_panel_filetype_list,
    right = M.right_panel_filetype_list,
}

M.get_panel_filetype_func = function(filetype, panel_filetype_list)
    local is_panel_filetype, func

    if panel_filetype_list then
        func = panel_filetype_list[filetype]
        if func ~= nil then
            is_panel_filetype = true
        end
    else
        for _, panel_filetype_list in pairs(M.panel_filetype_lists) do
            func = panel_filetype_list[filetype]
            if func ~= nil then
                is_panel_filetype = true
                break
            end
        end
    end

    return is_panel_filetype, func
end

M.is_panel_filetype = function(filetype, panel_filetype_list)
    local is_panel_filetype, _ = M.get_panel_filetype_func(filetype, panel_filetype_list)
    return is_panel_filetype
end

M.get_focused_panel_filetype = function(panel_filetype_list)
    local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
    local ok, func = M.get_panel_filetype_func(ft, panel_filetype_list)
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

M.get_opened_panel_filetype = function(panel_filetype_list)
    local opened = {}

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not vim.api.nvim_win_is_valid(win) then
            goto continue
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if utils.is_available("edgy.nvim") and ft == "edgy" then
            goto continue
        end

        if M.is_panel_filetype(ft, panel_filetype_list) then
            opened[#opened + 1] = win
        end

        ::continue::
    end

    return opened
end

M.toggle_panel = function(pos)
    local panel_filetype_list = M.panel_filetype_lists[pos]

    local is_focused, close_func = M.get_focused_panel_filetype(panel_filetype_list)
    if is_focused then
        close_func()
        return true
    end

    local opened = M.get_opened_panel_filetype(panel_filetype_list)
    if #opened > 0 then
        vim.api.nvim_set_current_win(opened[1])
        return true
    end

    return false
end

return M
