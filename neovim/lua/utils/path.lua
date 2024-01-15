local environment = require("utils.environment")

local M = {}

M.config_path = vim.fn.resolve(vim.fn.stdpath("config"))
if environment.is_windows then
    M.config_path = M.config_path:gsub("\\", "/")
end

M.data_path = vim.fn.resolve(vim.fn.stdpath("data"))
if environment.is_windows then
    M.data_path = M.data_path:gsub("\\", "/")
end
M.wsl_data_path = "/mnt/c/Users/MasouShizuka/AppData/Local/nvim-data"

M.home_path = vim.env.HOME
if environment.is_windows then
    M.home_path = M.home_path:gsub("\\", "/")
end

M.mason_install_root_path = M.data_path .. "/lazy/mason.nvim/mason"

M.msys2_path = "C:/msys64"

M.vscode_path = nil
if environment.is_windows then
    M.vscode_path = vim.env.APPDATA:gsub("\\", "/") .. "/Code"
elseif environment.is_mac then
    M.vscode_path = M.home_path .. "/Library/Application\\ Support/Code"
elseif environment.is_linux then
    M.vscode_path = M.home_path .. "/.config/Code"
end
M.vscode_snippet_path = M.vscode_path .. "/User/snippets"
M.vscode_extension_path = M.home_path .. "/.vscode/extensions"

M.conda_path = M.home_path .. "/miniconda3"
M.python_path = M.conda_path .. "/bin/python"
if environment.is_windows then
    M.python_path = M.conda_path .. "/python.exe"
end
M.get_python_envs_path = function()
    local python_envs_path = nil

    local conda_envs_path = M.conda_path .. "/envs"
    local envs = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local envs_path = conda_envs_path .. "/" .. envs
    if vim.fn.isdirectory(envs_path) ~= 0 then
        python_envs_path = envs_path .. "/bin/python"
        if environment.is_windows then
            python_envs_path = envs_path .. "/python.exe"
        end
    end

    return python_envs_path
end

return M
