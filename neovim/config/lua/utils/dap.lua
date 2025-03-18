local path = require("utils.path")
local utils = require("utils")

local M = {}

---@class dap_info
---@field config? fun(mason_nvim_dap: any): fun(config: any)
---@field download? boolean|fun():boolean
---@field enable? boolean|fun():boolean

---@type table<string, dap_info>
local dap_list = {
    codelldb = {
        config = function(mason_nvim_dap)
            return function(config)
                local command = path.mason_install_root_path .. "/packages/codelldb/extension/adapter/codelldb"
                local detached = true
                if require("utils.environment").is_windows then
                    command = command .. ".exe"
                    detached = false
                end

                config.adapters = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        -- CHANGE THIS to your path!
                        command = command,
                        args = { "--port", "${port}" },
                        -- On windows you may have to uncomment this:
                        detached = detached,
                    },
                }

                config.configurations = {
                    {
                        name = "Launch file",
                        type = "codelldb",
                        request = "launch",
                        program = function()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        cwd = "${workspaceFolder}",
                        stopOnEntry = false,
                    },
                }

                mason_nvim_dap.default_setup(config)
            end
        end,
        download = true,
        enable = function() return vim.fn.executable("gcc") == 1 end,
    },
    python = {
        config = function(mason_nvim_dap)
            return function(config)
                if not utils.is_available("nvim-dap-python") then
                    local adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/bin/python"
                    if require("utils.environment").is_windows then
                        adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/Scripts/python.exe"
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
                        config.adapters = {
                            type = "executable",
                            command = adapter_python_path,
                            args = { "-m", "debugpy.adapter" },
                            options = {
                                source_filetype = "python",
                            },
                        }
                    end
                end

                local python_path
                if not utils.is_available("nvim-dap-python") then
                    python_path = path.python_path
                    local python_envs_path = path.get_python_envs_path()
                    if python_envs_path then
                        python_path = python_envs_path
                    end
                end

                -- nvim-dap-python
                config.configurations = {
                    {
                        type = "python",
                        request = "launch",
                        name = "file",
                        program = "${file}",
                        pythonPath = python_path,
                    },
                    {
                        type = "python",
                        request = "launch",
                        name = "file:args",
                        program = "${file}",
                        args = function()
                            local args_string = vim.fn.input("Arguments: ")
                            local utils = require("dap.utils")
                            if utils.splitstr and vim.fn.has("nvim-0.10") == 1 then
                                return utils.splitstr(args_string)
                            end
                            return vim.split(args_string, " +")
                        end,
                        pythonPath = python_path,
                    },
                    {
                        type = "python",
                        request = "attach",
                        name = "attach",
                        connect = function()
                            local host = vim.fn.input("Host [127.0.0.1]: ")
                            host = host ~= "" and host or "127.0.0.1"
                            local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
                            return { host = host, port = port }
                        end,
                    },
                    {
                        type = "python",
                        request = "launch",
                        name = "file:doctest",
                        module = "doctest",
                        args = { "${file}" },
                        noDebug = true,
                        pythonPath = python_path,
                    },
                }

                mason_nvim_dap.default_setup(config)
            end
        end,
        download = true,
        enable = function() return vim.fn.executable("python") == 1 end,
    },
}

M.dap_config = {}
M.dap_list = {}
for dap, info in pairs(dap_list) do
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

        local download = info.download
        if download == nil then
            download = true
        end
        if type(download) == "function" then
            download = download()
        end
        if download then
            M.dap_list[#M.dap_list + 1] = dap
        end
    end
end

return M
