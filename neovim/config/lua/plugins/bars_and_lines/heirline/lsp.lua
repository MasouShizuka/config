local colors = require("utils.colors")
local icons = require("utils.icons")

local M = {}

M.lsp_server = {
    provider = function(self)
        local names = {}
        for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            names[#names + 1] = server.name
        end
        return icons.misc.gear .. table.concat(names, ",")
    end,
    hl = { fg = colors.colors.green },
    update = { "BufEnter", "LspAttach", "LspDetach" },
}

M.python_venv = {
    condition = function(self)
        return package.loaded["venv-selector"] and vim.api.nvim_get_option_value("filetype", { scope = "local" }) == "python"
    end,
    provider = function(self)
        local venv_name = "base"
        local active_venv = require("venv-selector").python()
        if active_venv ~= nil and active_venv:find("envs") then
            venv_name = vim.fn.fnamemodify(active_venv, ":h:t")
        end
        return icons.languages.python .. venv_name
    end,
    hl = { fg = colors.colors.green },
    on_click = {
        callback = function()
            require("venv-selector").open()
        end,
        name = "heirline_statusline_venv_selector",
    },
}

return M
