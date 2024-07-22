local environment = require("utils.environment")
local utils = require("utils")

local M = {}

local both = {
    toggle_cursor_center = function(buf)
        local toggle_setting
        if buf then
            toggle_setting = utils.toggle_buffer_setting
        else
            toggle_setting = utils.toggle_global_setting
        end

        toggle_setting("cursor_center_enabled", function(enabled, prev_enabled, global_enabled)
            if enabled then
                vim.cmd.normal({ "zz", bang = true })
            end
        end)
    end,
}

local vscode_only = {
    toggle_fileformat = function()
        require("vscode-neovim").action("workbench.action.editor.changeEOL")
    end,
    toggle_wrap = function()
        require("vscode-neovim").action("editor.action.toggleWordWrap")
    end,
}

local neovim_only = {
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

    for name, func in pairs(both) do
        M[name] = func
    end
    if environment.is_vscode then
        for name, func in pairs(vscode_only) do
            M[name] = func
        end
    else
        for name, func in pairs(neovim_only) do
            M[name] = func
        end
    end
end

return M
