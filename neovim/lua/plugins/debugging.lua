local variables = require("config.variables")

return {
    "mfussenegger/nvim-dap",
    config = function(_, opts)
        local icons = variables.icons.dap
        for name, sign in pairs(icons) do
            sign = type(sign) == "table" and sign or { sign }
            vim.fn.sign_define("Dap" .. name, { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] })
        end

        vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

        require("dap").set_log_level("ERROR")
    end,
    dependencies = {
        {
            "jay-babu/mason-nvim-dap.nvim",
            cmd = {
                "DapInstall",
                "DapUninstall",
            },
            config = function(_, opts)
                local handlers = {
                    function(config)
                        -- all sources with no handler get passed here

                        -- Keep original functionality
                        require("mason-nvim-dap").default_setup(config)
                    end,
                }
                for dap, setup in pairs(variables.dap()) do
                    handlers[dap] = setup
                end

                require("mason-nvim-dap").setup({
                    ensure_installed = variables.dap_list,
                    automatic_installation = true,
                    handlers = handlers,
                })
            end,
            dependencies = {
                "williamboman/mason.nvim",
            },
        },

        {
            "rcarriga/nvim-dap-ui",
            config = function(_, opts)
                local dap = require("dap")
                local dapui = require("dapui")
                dapui.setup(opts)
                dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open({})
                end
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                end
            end,
            keys = {
                { "<leader>du", function() require("dapui").toggle({}) end, desc = "Toggle ui", mode = "n" },
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
    enabled = not variables.is_vscode,
    init = function()
        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.register({
                mode = "n",
                ["<leader>d"] = {
                    name = "+dap",
                },
            })
        end
    end,
    keys = {
        { "<f5>",       function() require("dap").continue() end,          desc = "Continue",          mode = "n" },
        { "<leader>dr", function() require("dap").restart() end,           desc = "Restart",           mode = "n" },
        { "<f9>",       function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint", mode = "n" },
        { "<f10>",      function() require("dap").step_over() end,         desc = "Step over",         mode = "n" },
        { "<f11>",      function() require("dap").step_into() end,         desc = "Step into",         mode = "n" },
        { "<s-f11>",    function() require("dap").step_out() end,          desc = "Step out",          mode = "n" },
        { "<f6>",       function() require("dap").pause() end,             desc = "Pause",             mode = "n" },
        { "<leader>dk", function() require("dap").up() end,                desc = "Up",                mode = "n" },
        { "<leader>dj", function() require("dap").down() end,              desc = "Down",              mode = "n" },
        { "<s-f5>",     function() require("dap").disconnect() end,        desc = "Disconnent",        mode = "n" },
        { "<leader>dh", function() require("dap.ui.widgets").hover() end,  desc = "Hover",             mode = "n" },
    },
}
