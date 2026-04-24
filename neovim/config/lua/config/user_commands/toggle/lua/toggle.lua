local M = {}

local vscode = {
    toggle_fileformat = function() require("vscode-neovim").action("workbench.action.editor.changeEOL") end,
    toggle_wrap = function() require("vscode-neovim").action("editor.action.toggleWordWrap") end,
}

local nvim = {
    toggle_diagnostic = function(opts) vim.diagnostic.enable(not vim.diagnostic.is_enabled(opts), opts) end,
    toggle_fileformat = function(opts)
        local utils = require("utils")
        utils.toggle_option("fileformat", vim.tbl_deep_extend("force", {
            callback = function(enabled, prev_enabled)
                vim.cmd.write()
                utils.refresh_buf()
            end,
            list = { "dos", "unix" },
        }, opts))
    end,
    toggle_spell = function(opts) require("utils").toggle_option("spell", opts) end,
    toggle_syntax = function(opts)
        local global = opts.global or false
        local option_opts = { scope = global and "global" or "local" }

        local syntax = vim.api.nvim_get_option_value("syntax", option_opts)
        if syntax == "" then
            vim.api.nvim_set_option_value("syntax", "on", option_opts)
        end

        require("utils").toggle_option("syntax", vim.tbl_deep_extend("force", {
            callback = function(enabled, prev_enabled)
                if enabled == "on" then
                    vim.treesitter.start()
                else
                    vim.treesitter.stop()
                end
                vim.api.nvim_set_option_value("syntax", enabled, option_opts)
            end,
            list = { "on", "off" },
        }, opts))
    end,
    toggle_wrap = function(opts) require("utils").toggle_option("wrap", opts) end,
}

M.setup = function(opts)
    M.vscode = vscode
    M.nvim = nvim
end

return M
