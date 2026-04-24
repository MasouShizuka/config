local environment = require("utils.environment")
local path = require("utils.path")

local M = {}

---@class dap_info
---@field adapter? dap.Adapter|dap.AdapterFactory
---@field configuration? dap.Configuration[]
---@field filetypes? table<string,boolean|fun():boolean>
---@field enable? boolean|fun():boolean

---@type table<string, dap_info>
local dap_infos = {
    codelldb = {
        adapter = {
            type = "executable",
            command = path.codelldb_path, -- or if not in $PATH: "/absolute/path/to/codelldb"

            -- On windows you may have to uncomment this:
            detached = not environment.is_windows,
        },
        configuration = {
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
        },
        enable = path.codelldb_extension_path ~= nil,
        filetypes = {
            cpp = true,
            rust = function()
                return not require("utils").is_available("rustaceanvim")
            end,
        },
    },
    python = {
        adapter = function(cb, config)
            if require("utils").is_available("nvim-dap-python") then
                return
            end

            if config.request == "attach" then
                ---@diagnostic disable-next-line: undefined-field
                local port = (config.connect or config).port
                ---@diagnostic disable-next-line: undefined-field
                local host = (config.connect or config).host or "127.0.0.1"
                cb({
                    type = "server",
                    port = assert(port, "`connect.port` is required for a python `attach` configuration"),
                    host = host,
                    options = {
                        source_filetype = "python",
                    },
                })
            else
                cb({
                    type = "executable",
                    command = path.get_python_envs_path(),
                    args = { "-m", "debugpy.adapter" },
                    options = {
                        source_filetype = "python",
                    },
                })
            end
        end,
        configuration = {
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
                        return path.get_python_envs_path()
                    end
                end,
            },
        },
        enable = vim.fn.executable("python") == 1,
    },
}

---@type string[]
M.dap_list = {}
---@type table<string,dap.Adapter|dap.AdapterFactory>
M.dap_adapters = {}
---@type table<string,dap.Configuration[]>
M.dap_configurations = {}
for dap, info in pairs(dap_infos) do
    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if not enable then
        goto continue
    end

    M.dap_list[#M.dap_list + 1] = dap

    if info.adapter then
        M.dap_adapters[dap] = info.adapter
    end

    if info.configuration then
        if info.filetypes then
            for ft, ft_enable in pairs(info.filetypes) do
                if type(ft_enable) == "function" then
                    ft_enable = ft_enable()
                end
                if ft_enable then
                    M.dap_configurations[ft] = info.configuration
                end
            end
        else
            M.dap_configurations[dap] = info.configuration
        end
    end

    ::continue::
end

return M
