local variables = require("config.variables")

return {
    {
        "karb94/neoscroll.nvim",
        config = function(_, opts)
            require("neoscroll").setup(opts)

            local t = {}
            -- Syntax: t[keys] = {function, {function arguments}}
            -- t["<c-u>"] = {"scroll", {"-vim.wo.scroll", "true", "250"}}
            -- t["<c-d>"] = {"scroll", { "vim.wo.scroll", "true", "250"}}
            t["<c-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100" } }
            t["<c-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } }
            -- t["<c-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } }
            -- t["<c-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } }
            -- t["<c-y>"] = { "scroll", { "-0.10", "false", "100" } }
            -- t["<c-e>"] = { "scroll", { "0.10", "false", "100" } }
            -- t["zt"]    = { "zt", { "250" } }
            -- t["zz"]    = { "zz", { "250" } }
            -- t["zb"]    = { "zb", { "250" } }

            require("neoscroll.config").set_mappings(t)
        end,
        keys = {
            { "<c-u>", desc = "Scroll half page up",   mode = { "n", "x" } },
            { "<c-d>", desc = "Scroll half page down", mode = { "n", "x" } },
        },
        opts = {
            -- All these keys will be mapped to their corresponding default scrolling animation
            -- mappings = { "<c-u>", "<c-d>", "<c-b>", "<c-f>", "<c-y>", "<c-e>", "zt", "zz", "zb" },
            mappings = { "<c-u>", "<c-d>" },
            -- hide_cursor = true,       -- Hide cursor while scrolling
            hide_cursor = false,
            stop_eof = true,             -- Stop at <EOF> when scrolling downwards
            respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
            cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
            easing_function = nil,       -- Default easing function
            pre_hook = nil,              -- Function to run before the scrolling animation starts
            post_hook = nil,             -- Function to run after the scrolling animation ends
            performance_mode = false,    -- Disable "Performance Mode" on all buffers.
        },
    },

    {
        "lewis6991/satellite.nvim",
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        opts = {
            current_only = false,
            -- winblend = 50,
            winblend = 0,
            zindex = 40,
            excluded_filetypes = {},
            width = 2,
            handlers = {
                search = {
                    enable = true,
                },
                diagnostic = {
                    enable = true,
                    signs = { "-", "=", "≡" },
                    min_severity = vim.diagnostic.severity.HINT,
                },
                gitsigns = {
                    enable = true,
                    signs = {
                        -- can only be a single character (multibyte is okay)
                        add = "│",
                        change = "│",
                        delete = "-",
                    },
                },
                marks = {
                    -- enable = true,
                    enable = false,
                    show_builtins = false, -- shows the builtin marks like [ ] < >
                },
            },
        },
    },
}
