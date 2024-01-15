local environment = require("utils.environment")
local path = require("utils.path")

local M = {}

M.dap = function(mason_nvim_dap)
    return {
        codelldb = function(config)
            local detached = true
            if environment.is_windows then
                detached = false
            end
            config.adapters = {
                type = "server",
                port = "${port}",
                executable = {
                    -- CHANGE THIS to your path!
                    command = path.mason_install_root_path .. "/packages/codelldb/extension/adapter/codelldb",
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
        python = function(config)
            config.adapters = {
                type = "executable",
                command = path.python_path,
                args = { "-m", "debugpy.adapter" },
                options = {
                    source_filetype = "python",
                },
            }

            config.configurations = {
                {
                    -- The first three options are required by nvim-dap
                    type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                    request = "launch",
                    name = "Launch file",
                    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

                    program = "${file}", -- This configuration will launch the current file if used.
                    pythonPath = function()
                        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itM.
                        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                        local cwd = vim.fn.getcwd()
                        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                            return cwd .. "/venv/bin/python"
                        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                            return cwd .. "/.venv/bin/python"
                        else
                            return path.python_path
                        end
                    end,
                },
            }

            mason_nvim_dap.default_setup(config)
        end,
    }
end

M.dap_list = vim.tbl_keys(M.dap())

return M
