local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

local M = {}

---@class dap_info
---@field config? fun(mason_nvim_dap: any):fun(config: any)
---@field download? boolean|fun():boolean
---@field enable? boolean|fun():boolean
---@field mason? string|{ version?:string, auto_update?:boolean, condition?:fun():boolean }

---@type table<string, dap_info>
local dap_list = {
    codelldb = {
        config = function(mason_nvim_dap)
            return function(config)
                mason_nvim_dap.default_setup(config)
            end
        end,
        download = environment.is_gcc_exist or environment.is_clang_exist,
        enable = environment.is_gcc_exist or environment.is_clang_exist,
    },
    python = {
        config = function(mason_nvim_dap)
            return function(config)
                if utils.is_available("nvim-dap-python") then
                    return
                end

                if config.request == "attach" then
                    ---@diagnostic disable-next-line: undefined-field
                    local port = (config.connect or config).port
                    ---@diagnostic disable-next-line: undefined-field
                    local host = (config.connect or config).host or "127.0.0.1"
                    config.adapters = {
                        type = "server",
                        port = assert(port, "`connect.port` is required for a python `attach` configuration"),
                        host = host,
                        options = {
                            source_filetype = "python",
                        },
                    }
                else
                    local adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/bin/python"
                    if require("utils.environment").is_windows then
                        adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/Scripts/python.exe"
                    end

                    config.adapters = {
                        type = "executable",
                        command = adapter_python_path,
                        args = { "-m", "debugpy.adapter" },
                        options = {
                            source_filetype = "python",
                        },
                    }
                end

                config.configurations[1].pythonPath = function()
                    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                    local cwd = vim.fn.getcwd()
                    if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                        return cwd .. "/venv/bin/python"
                    elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                        return cwd .. "/.venv/bin/python"
                    else
                        local python_path = path.python_path
                        local python_envs_path = path.get_python_envs_path()
                        if python_envs_path then
                            python_path = python_envs_path
                        end
                        return python_path
                    end
                end

                mason_nvim_dap.default_setup(config)
            end
        end,
        download = environment.is_python_exist,
        enable = environment.is_python_exist,
        mason = "debugpy",
    },
}

M.dap_list_for_mason = {}
M.dap_config = {}
for dap, info in pairs(dap_list) do
    local download = info.download
    if download == nil then
        download = true
    end
    if type(download) == "function" then
        download = download()
    end
    if download then
        M.dap_list_for_mason[#M.dap_list_for_mason + 1] = info.mason or dap
    end

    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if enable then
        M.dap_config[dap] = info.config or function(mason_nvim_dap, default_config)
            return function(config)
                mason_nvim_dap[dap].default_setup(vim.tbl_deep_extend("force", default_config, {}))
            end
        end
    end
end

return M
