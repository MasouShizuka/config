local utils = require("utils")

local M = {}

local function toggle_cursor_center(curr_buf_only, center_cursor)
    local curr_buf
    local toggle_setting
    if curr_buf_only then
        curr_buf = vim.api.nvim_get_current_buf()
        toggle_setting = utils.toggle_buffer_setting
    else
        toggle_setting = utils.toggle_global_setting
    end

    toggle_setting("cursor_center_enabled", function(enabled, prev_enabled, global_enabled)
        local augroup = "CursorCenter"
        if curr_buf_only then
            augroup = string.format("%s%s", augroup, curr_buf)
        end

        if enabled then
            center_cursor()
            if curr_buf_only then
                vim.api.nvim_create_autocmd("CursorMoved", {
                    buffer = curr_buf,
                    callback = function()
                        center_cursor()
                    end,
                    desc = "Center cursor",
                    group = vim.api.nvim_create_augroup(augroup, { clear = true }),
                })
            else
                vim.api.nvim_create_autocmd("CursorMoved", {
                    callback = function()
                        center_cursor()
                    end,
                    desc = "Center cursor",
                    group = vim.api.nvim_create_augroup(augroup, { clear = true }),
                })
            end
        else
            vim.api.nvim_del_augroup_by_name(augroup)
        end
    end)
end

local vscode_only = {
    toggle_cursor_center = function(curr_buf_only)
        toggle_cursor_center(curr_buf_only, function()
            vim.cmd.normal("zz")
        end)
    end,
    toggle_fileformat = function()
        require("vscode-neovim").action("workbench.action.editor.changeEOL")
    end,
    toggle_wrap = function()
        require("vscode-neovim").action("editor.action.toggleWordWrap")
    end,
}

local neovim_only = {
    toggle_cursor_center = function(curr_buf_only)
        toggle_cursor_center(curr_buf_only, function()
            vim.cmd.normal({ "zz", bang = true })
        end)
    end,
    toggle_fileformat = function()
        utils.toggle_local_option("fileformat", { "dos", "unix" }, function(enabled, prev_enabled)
            vim.cmd.write()
            utils.refresh_buf()
        end)
    end,
    toggle_spell = function()
        utils.toggle_local_option("spell")
    end,
    toggle_syntax = function()
        local syntax = vim.api.nvim_get_option_value("syntax", { scope = "local" })
        if syntax == "" then
            vim.api.nvim_set_option_value("syntax", "on", { scope = "local" })
        end

        utils.toggle_local_option("syntax", { "on", "off" }, function(enabled, prev_enabled)
            local buf = vim.api.nvim_get_current_buf()
            local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
            local is_treesitter_available = ts_avail and parsers.has_parser()
            if is_treesitter_available then
                if enabled == "off" then
                    vim.treesitter.stop(buf)
                    vim.api.nvim_set_option_value("syntax", "off", { scope = "local" })
                else
                    vim.treesitter.start(buf)
                    vim.api.nvim_set_option_value("syntax", "on", { scope = "local" })
                end
            end
        end)
    end,
    toggle_wrap = function()
        utils.toggle_local_option("wrap")
    end,
}

M.setup = function(opts)
    if vim.g.cursor_center_enabled == nil then
        vim.g.cursor_center_enabled = false
    end

    M.vscode = vscode_only
    M.nvim = neovim_only
end

return M
