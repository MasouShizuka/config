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

M.mason_install_root_path = M.data_path .. "/lazy/mason.nvim/mason"
M.package_config_path = M.config_path .. "/package_config"

M.home_path = vim.env.HOME
if environment.is_windows then
    M.home_path = M.home_path:gsub("\\", "/")
end

if environment.is_windows then
    M.scoop_path = M.home_path .. "/scoop"
    M.scoop_app_path = M.scoop_path .. "/apps"
    M.scoop_persist_path = M.scoop_path .. "/persist"

    M.msys2_path = M.scoop_app_path .. "/msys2/current"
end

M.vscode_user_data_path = nil
M.vscode_extension_path = M.home_path .. "/.vscode/extensions"
if environment.is_windows then
    M.vscode_user_data_path = M.scoop_persist_path .. "/vscode/data/user-data"
    M.vscode_extension_path = M.scoop_persist_path .. "/vscode/data/extensions"
elseif environment.is_mac then
    M.vscode_user_data_path = M.home_path .. "/Library/Application\\ Support/Code"
elseif environment.is_linux then
    M.vscode_user_data_path = M.home_path .. "/.config/Code"
end
M.vscode_snippet_path = M.vscode_user_data_path .. "/User/snippets"

M.conda_path = M.home_path .. "/mambaforge"
M.python_path = M.conda_path .. "/bin/python"
if environment.is_windows then
    M.conda_path = M.scoop_app_path .. "/mambaforge/current"
    M.python_path = M.conda_path .. "/python.exe"
end
M.get_python_envs_path = function()
    local python_envs_path
    if utils.is_available("venv-selector.nvim") then
        return python_envs_path
    end

    local conda_envs_path = M.conda_path .. "/envs"
    local envs_path = conda_envs_path .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    if vim.fn.isdirectory(envs_path) ~= 0 then
        python_envs_path = envs_path .. "/bin/python"
        if environment.is_windows then
            python_envs_path = envs_path .. "/python.exe"
        end
    end

    return python_envs_path
end

return M
