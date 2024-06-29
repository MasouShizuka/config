local environment = require("utils.environment")
local utils = require("utils")

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

M.get_python_envs_path = function(envs)
    local python_envs_path = nil

    local conda_envs_path = M.conda_path .. "/envs"
    local envs_path = conda_envs_path .. "/" .. envs
    if vim.fn.isdirectory(envs_path) ~= 0 then
        python_envs_path = envs_path .. "/bin/python"
        if environment.is_windows then
            python_envs_path = envs_path .. "/python.exe"
        end
    end

    return python_envs_path
end
M.conda_path = M.home_path .. "/mambaforge"
M.python_path = M.conda_path .. "/bin/python"
if environment.is_windows then
    M.python_path = M.conda_path .. "/python.exe"
end
M.python_envs_path = nil
if not utils.is_available("venv-selector.nvim") then
    local envs = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local python_envs_path = M.get_python_envs_path(envs)
    if python_envs_path then
        M.python_envs_path = python_envs_path
    end
end

return M
