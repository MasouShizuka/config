local variables = require("variables")

return {
    "mfussenegger/nvim-dap",
    cond = not variables.is_vscode,
    config = function(_, opts)
        local icons = variables.icons.dap
        for name, sign in pairs(icons) do
            sign = type(sign) == "table" and sign or { sign }
            vim.fn.sign_define(
                "Dap" .. name,
                { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
            )
        end

        vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

        vim.keymap.set("n", "<Leader>dr", function() require("dap").restart() end, { silent = true })
        vim.keymap.set("n", "<Leader>dk", function() require("dap").up() end, { silent = true })
        vim.keymap.set("n", "<Leader>dj", function() require("dap").down() end, { silent = true })
        vim.keymap.set("n", "<Leader>dh", function() require("dap.ui.widgets").hover() end, { silent = true })
    end,
    dependencies = {
        {
            "jay-babu/mason-nvim-dap.nvim",
            cmd = { "DapInstall", "DapUninstall" },
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
                { "<Leader>du", function() require("dapui").toggle({}) end, mode = "n" },
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
    keys = {
        { "<F5>",    function() require("dap").continue() end,          mode = "n" },
        { "<F9>",    function() require("dap").toggle_breakpoint() end, mode = "n" },
        { "<F10>",   function() require("dap").step_over() end,         mode = "n" },
        { "<F11>",   function() require("dap").step_into() end,         mode = "n" },
        { "<S-F11>", function() require("dap").step_out() end,          mode = "n" },
        { "<F6>",    function() require("dap").pause() end,             mode = "n" },
        { "<S-F5>",  function() require("dap").disconnect() end,       mode = "n" },
    },
}
