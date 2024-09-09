local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

local M = {}

M.dap = function(mason_nvim_dap)
    return {
        codelldb = function(config)
            local command = path.mason_install_root_path .. "/packages/codelldb/extension/adapter/codelldb"
            local detached = true
            if environment.is_windows then
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
        end,
        -- 由 nvim-jdtls 设置
        javadbg = function(config) end,
        -- 由 nvim-jdtls 设置
        javatest = function(config) end,
        python = function(config)
            if not utils.is_available("nvim-dap-python") then
                local adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/bin/python"
                if environment.is_windows then
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

                local python_path = path.python_path
                local python_envs_path = path.get_python_envs_path()
                if python_envs_path then
                    python_path = python_envs_path
                end
                config.configurations = {
                    {
                        -- The first three options are required by nvim-dap
                        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                        request = "launch",
                        name = "Launch file",

                        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

                        program = "${file}", -- This configuration will launch the current file if used.
                        pythonPath = function()
                            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                            local cwd = vim.fn.getcwd()
                            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                                return cwd .. "/venv/bin/python"
                            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                                return cwd .. "/.venv/bin/python"
                            else
                                return python_path
                            end
                        end,
                    },
                }

                mason_nvim_dap.default_setup(config)
            end
        end,
    }
end

M.dap_list = vim.tbl_keys(M.dap())

return M
