local variables = require("config.variables")

return {
    {
        "dstein64/nvim-scrollview",
        cmd = {
            "ScrollViewDisable",
            "ScrollViewEnable",
            "ScrollViewToggle",
            "ScrollViewRefresh",
            "ScrollViewNext",
            "ScrollViewPrev",
            "ScrollViewFirst",
            "ScrollViewLast",
        },
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {
            current_only = true,
            excluded_filetypes = variables.skip_filetype_list,
            line_limit = -1,
            signs_column = 0,
            signs_on_startup = {
                "conflicts",
                -- "cursor",
                "diagnostics",
                "folds",
                "loclist",
                "marks",
                "quickfix",
                "search",
                "spell",
                -- "textwidth",
                -- "trail",
            },
            diagnostics_severities = {
                vim.diagnostic.severity.ERROR,
                vim.diagnostic.severity.WARN,
            },
        },
    },

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
}
