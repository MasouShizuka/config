local variables = require("config.variables")

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = {
            "Telescope",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.register({
                    mode = "n",
                    ["<leader>t"] = {
                        name = "+telescope",
                    },
                })
            end
        end,
        keys = {
            { "<leader>t/", function(...) require("telescope.builtin").live_grep(...) end,       desc = "Live grep",       mode = "n" },
            { "<c-p>",      function(...) require("telescope.builtin").find_files(...) end,      desc = "Find files",      mode = "n" },
            { "<leader>to", function(...) require("telescope.builtin").oldfiles(...) end,        desc = "Old files",       mode = "n" },
            { "<leader>t:", function(...) require("telescope.builtin").command_history(...) end, desc = "Command history", mode = "n" },
            { "<leader>th", function(...) require("telescope.builtin").help_tags(...) end,       desc = "Help tags",       mode = "n" },
            { "<leader>tb", function(...) require("telescope.builtin").buffers(...) end,         desc = "Buffers",         mode = "n" },
            { "<leader>tr", function(...) require("telescope.builtin").registers(...) end,       desc = "Registers",       mode = "n" },
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<c-j>"] = function(...) require("telescope.actions").move_selection_next(...) end,
                        ["<c-k>"] = function(...) require("telescope.actions").move_selection_previous(...) end,
                        ["<c-w>"] = function(...) require("telescope.actions").close(...) end,
                    },
                },
                history = false,
                file_ignore_patterns = {
                    "%.git",
                    "node_modules",
                },
            },
        },
    },
}
