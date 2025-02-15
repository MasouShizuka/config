-- nvim-docs-view
-- https://github.com/amrbashir/nvim-docs-view

local M = {}

local default_config = {
    filetype = "extra-view",

    focus = false,

    height = 10,
    width = 60,
    position = "right",

    init = nil,
}

local function extra_view_toggle(update, opts)
    local config = vim.tbl_deep_extend("force", default_config, opts)

    for group in vim.fn.execute("augroup"):gmatch("%S+") do
        if group == config.filetype then
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if not vim.api.nvim_win_is_valid(win) then
                    goto continue
                end

                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if ft == config.filetype then
                    vim.api.nvim_win_close(win, true)
                    vim.api.nvim_del_augroup_by_name(config.filetype)

                    break
                end

                ::continue::
            end

            return
        end
    end

    local prev_win = vim.api.nvim_get_current_win()

    local height = config.height
    if type(height) == "function" then
        height = config.height()
    end
    local width = config.width
    if type(width) == "function" then
        width = config.width()
    end

    if config.position == "bottom" then
        vim.api.nvim_command("bel new")
        width = vim.api.nvim_win_get_width(prev_win)
    elseif config.position == "top" then
        vim.api.nvim_command("top new")
        width = vim.api.nvim_win_get_width(prev_win)
    elseif config.position == "left" then
        vim.api.nvim_command("topleft vnew")
        height = vim.api.nvim_win_get_height(prev_win)
    else
        vim.api.nvim_command("botright vnew")
        height = vim.api.nvim_win_get_height(prev_win)
    end

    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_height(win, height)
    vim.api.nvim_win_set_width(win, width)
    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win })

    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("filetype", config.filetype, { buf = buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

    if config.init and type(config.init) == "function" then
        config.init(buf, win)
    end

    if not config.focus then
        vim.api.nvim_set_current_win(prev_win)
    end

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function()
            update(buf, win)
        end,
        desc = config.filetype .. " auto update",
        group = vim.api.nvim_create_augroup(config.filetype, { clear = true }),
    })
end

M.setup = function(opts)
    default_config = vim.tbl_deep_extend("force", default_config, opts or {})

    M.extra_view_toggle = extra_view_toggle
end

return M
