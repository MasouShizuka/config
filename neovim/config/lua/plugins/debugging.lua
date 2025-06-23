local environment = require("utils.environment")

return {
    {
        "mfussenegger/nvim-dap",
        config = function(_, opts)
            local icons = require("utils.icons")

            local signs = {
                DapBreakpoint = { text = icons.dap.Breakpoint, texthl = "DiagnosticError" },
                DapBreakpointCondition = { text = icons.dap.BreakpointCondition, texthl = "DiagnosticInfo" },
                DapBreakpointRejected = { text = icons.dap.BreakpointRejected, texthl = "DiagnosticError" },
                DapLogPoint = { text = icons.dap.LogPoint, texthl = "DiagnosticInfo" },
                DapStopped = { text = icons.dap.Stopped, texthl = "DiagnosticWarn", linehl = "Visual", numhl = "Visual" },
            }
            for name, sign in pairs(signs) do
                vim.fn.sign_define(name, sign)
            end
        end,
        dependencies = {
            {
                "jay-babu/mason-nvim-dap.nvim",
                cmd = {
                    "DapInstall",
                    "DapUninstall",
                },
                dependencies = {
                    "williamboman/mason.nvim",
                },
                opts = function()
                    local handlers = {
                        -- function(config)
                        --     -- all sources with no handler get passed here
                        --
                        --     -- Keep original functionality
                        --     mason_nvim_dap.default_setup(config)
                        -- end,
                    }
                    for dap_server, setup in pairs(require("utils.dap").dap_config) do
                        handlers[dap_server] = setup(require("mason-nvim-dap"))
                    end

                    return {
                        handlers = handlers,
                    }
                end,
            },

            {
                "rcarriga/nvim-dap-ui",
                config = function(_, opts)
                    local dap, dapui = require("dap"), require("dapui")
                    dapui.setup(opts)
                    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
                    -- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
                    -- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end
                end,
                dependencies = {
                    "nvim-neotest/nvim-nio",
                },
                keys = {
                    { "<leader>dd", function() require("dapui").toggle() end, desc = "Toggle dapui", mode = "n" },
                },
                opts = {
                    floating = {
                        border = "rounded",
                    },
                },
            },

            {
                "theHamsta/nvim-dap-virtual-text",
                dependencies = {
                    "nvim-treesitter/nvim-treesitter",
                },
                opts = {},
            },
        },
        enabled = not environment.is_vscode and environment.dap_enable,
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>d", group = "dap", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for dap",
                    pattern = "IceLoad",
                })
            end
        end,
        keys = {
            {
                "<f5>",
                function()
                    local utils = require("utils")

                    local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
                    -- nvim-dap-python 会优先使用 CONDA_PREFIX 而忽略 venv-selector 切换环境时设置的 resolve_python
                    -- 因此，每次执行 dap 时清除 CONDA_PREFIX
                    if ft == "python" and utils.is_available("nvim-dap-python") and utils.is_available("venv-selector.nvim") then
                        vim.fn.setenv("CONDA_PREFIX", nil)
                    end

                    require("dap").continue()
                end,
                desc = "Continue",
                mode = "n",
            },
            { "<leader>dl", function() require("dap").run_last() end,                                                    desc = "Run Last",                mode = "n" },
            { "<leader>dr", function() require("dap").restart() end,                                                     desc = "Restart",                 mode = "n" },
            { "<leader>db", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Breakpoint with message", mode = "n" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,        desc = "Breakpoint Condition",    mode = "n" },
            { "<f9>",       function() require("dap").toggle_breakpoint() end,                                           desc = "Toggle breakpoint",       mode = "n" },
            { "<f10>",      function() require("dap").step_over() end,                                                   desc = "Step over",               mode = "n" },
            { "<f11>",      function() require("dap").step_into() end,                                                   desc = "Step into",               mode = "n" },
            { "<s-f11>",    function() require("dap").step_out() end,                                                    desc = "Step out",                mode = "n" },
            { "<f6>",       function() require("dap").pause() end,                                                       desc = "Pause",                   mode = "n" },
            { "<leader>dk", function() require("dap").up() end,                                                          desc = "Up",                      mode = "n" },
            { "<leader>dj", function() require("dap").down() end,                                                        desc = "Down",                    mode = "n" },
            { "<leader>dc", function() require("dap").run_to_cursor() end,                                               desc = "Run to Cursor",           mode = "n" },
            {
                "<s-f5>",
                function()
                    require("dap").disconnect()
                    require("dapui").close()
                end,
                desc = "Disconnent",
                mode = "n",
            },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover", mode = "n" },
        },
    },
}
