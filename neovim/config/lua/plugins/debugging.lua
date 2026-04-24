local environment = require("utils.environment")

return {
    {
        "mfussenegger/nvim-dap",
        cond = not environment.is_vscode and environment.dap_enable,
        config = function(_, opts)
            local dap = require("utils.dap")
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

            for dap_server, adapter in pairs(dap.dap_adapters) do
                require("dap").adapters[dap_server] = adapter
            end
            for dap_server, configuration in pairs(dap.dap_configurations) do
                require("dap").configurations[dap_server] = configuration
            end
        end,
        dependencies = {
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
                    "romus204/tree-sitter-manager.nvim",
                },
                opts = {},
            },
        },
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
                        vim.fn.setenv("CONDA_PREFIX", vim.v.null)
                    end

                    require("dap").continue()
                end,
                desc = "Continue",
                mode = "n",
            },
            { "<leader>dL", function() require("dap").run_last() end,                                             desc = "Run Last",             mode = "n" },
            { "<leader>dr", function() require("dap").restart() end,                                              desc = "Restart",              mode = "n" },
            { "<leader>db", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition", mode = "n" },
            { "<f9>",       function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle breakpoint",    mode = "n" },
            { "<f10>",      function() require("dap").step_over() end,                                            desc = "Step over",            mode = "n" },
            { "<f11>",      function() require("dap").step_into() end,                                            desc = "Step into",            mode = "n" },
            { "<s-f11>",    function() require("dap").step_out() end,                                             desc = "Step out",             mode = "n" },
            { "<f6>",       function() require("dap").pause() end,                                                desc = "Pause",                mode = "n" },
            { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up",                   mode = "n" },
            { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down",                 mode = "n" },
            { "<leader>dc", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor",        mode = "n" },
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
