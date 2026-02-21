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


if environment.is_windows then
    M.scoop_path = M.home_path .. "/scoop"
    M.scoop_app_path = M.scoop_path .. "/apps"
    M.scoop_persist_path = M.scoop_path .. "/persist"
elseif environment.is_wsl then
    M.scoop_path = M.windows_userprofile .. "/scoop"
    M.scoop_app_path = M.scoop_path .. "/apps"
    M.scoop_persist_path = M.scoop_path .. "/persist"
end

M.package_config_path = M.config_path .. "/package_config"

if environment.is_windows then
    M.sioyek_path = M.scoop_app_path .. "/sioyek/current/sioyek"
else
    M.sioyek_path = "sioyek"
end

if environment.is_windows then
    M.sqlite_path = M.scoop_app_path .. "/sqlite-with-dll/current/sqlite3.dll"
else
    M.sqlite_path = "sqlite3.dll"
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

local paths = vim.fn.glob(M.vscode_extension_path .. "/vadimcn.vscode-lldb-*", 0, 1)
if #paths ~= 0 then
    M.codelldb_extension_path = paths[#paths]
    M.codelldb_path = M.codelldb_extension_path .. "/adapter/codelldb"
    M.liblldb_path = M.codelldb_extension_path .. "/lldb/lib/liblldb"
    if environment.is_windows then
        M.codelldb_path = M.codelldb_path .. ".exe"
        M.liblldb_path = M.codelldb_extension_path .. "/lldb/bin/liblldb.dll"
    elseif environment.is_mac then
        M.liblldb_path = M.liblldb_path .. ".dylib"
    elseif environment.is_linux then
        M.liblldb_path = M.liblldb_path .. ".so"
    end
end

if environment.is_windows then
    M.conda_path = M.scoop_app_path .. "/mambaforge/current"
    M.python_path = M.conda_path .. "/python.exe"
else
    M.conda_path = M.home_path .. "/mambaforge"
    M.python_path = M.conda_path .. "/bin/python"
end
M.get_python_envs_path = function()
    local python_envs_path

    local conda_envs_path = M.conda_path .. "/envs"
    local envs_path = conda_envs_path .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    if vim.fn.isdirectory(envs_path) ~= 0 then
        if environment.is_windows then
            python_envs_path = envs_path .. "/python.exe"
        else
            python_envs_path = envs_path .. "/bin/python"
        end
    end

    if python_envs_path then
        return python_envs_path
    end
    return M.python_path
end

return M
