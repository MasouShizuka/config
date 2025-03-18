local environment = require("utils.environment")

local M = {}

M.home_path = vim.env.HOME
if environment.is_windows then
    M.home_path = M.home_path:gsub("\\", "/")
end
if environment.is_wsl then
    local utils = require("utils")
    M.windows_localappdata = utils.get_windows_path_from_wsl("LOCALAPPDATA")
    M.windows_userprofile = utils.get_windows_path_from_wsl("USERPROFILE")
end


M.config_path = vim.fn.resolve(vim.fn.stdpath("config"))
if environment.is_windows then
    M.config_path = M.config_path:gsub("\\", "/")
end

M.data_path = vim.fn.resolve(vim.fn.stdpath("data"))
if environment.is_windows then
    M.data_path = M.data_path:gsub("\\", "/")
end
if environment.is_wsl then
    M.windows_data_path = M.windows_localappdata .. "/nvim-data"
end


M.mason_install_root_path = M.data_path .. "/lazy/mason.nvim/mason"
M.package_config_path = M.config_path .. "/package_config"


if environment.is_windows then
    M.scoop_path = M.home_path .. "/scoop"
    M.scoop_app_path = M.scoop_path .. "/apps"
    M.scoop_persist_path = M.scoop_path .. "/persist"
elseif environment.is_wsl then
    M.scoop_path = M.windows_userprofile .. "/scoop"
    M.scoop_app_path = M.scoop_path .. "/apps"
    M.scoop_persist_path = M.scoop_path .. "/persist"
end


M.sioyek_path = "sioyek"
if environment.is_windows then
    M.sioyek_path = M.scoop_app_path .. "/sioyek/current/sioyek"
end

M.sqlite_path = "sqlite3.dll"
if environment.is_windows then
    M.sqlite_path = M.scoop_app_path .. "/sqlite-with-dll/current/sqlite3.dll"
end


M.vscode_user_data_path = nil
M.vscode_extension_path = M.home_path .. "/.vscode/extensions"
if environment.is_windows or environment.is_wsl then
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
    if require("utils").is_available("venv-selector.nvim") then
        return nil
    end

    local python_envs_path

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
