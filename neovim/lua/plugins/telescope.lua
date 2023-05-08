local variables = require("variables")

return {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    cond = not variables.is_vscode,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        {
            "<Leader>t/",
            function(...)
                require("telescope.builtin").live_grep(...)
            end,
            mode = "n",
        },
        {
            "<C-p>",
            function(...)
                require("telescope.builtin").find_files(...)
            end,
            mode = "n",
        },
        {
            "<Leader>to",
            function(...)
                require("telescope.builtin").oldfiles(...)
            end,
            mode = "n",
        },
        {
            "<Leader>t:",
            function(...)
                require("telescope.builtin").command_history(...)
            end,
            mode = "n",
        },
        {
            "<Leader>th",
            function(...)
                require("telescope.builtin").help_tags(...)
            end,
            mode = "n",
        },
        {
            "<Leader>tb",
            function(...)
                require("telescope.builtin").buffers(...)
            end,
            mode = "n",
        },
        {
            "<Leader>tr",
            function(...)
                require("telescope.builtin").registers(...)
            end,
            mode = "n",
        },
    },
    opts = {
        defaults = {
            mappings = {
                i = {
                    ["<C-j>"] = function(...)
                        require("telescope.actions").move_selection_next(...)
                    end,
                    ["<C-k>"] = function(...)
                        require("telescope.actions").move_selection_previous(...)
                    end,
                    ["<C-w>"] = function(...)
                        require("telescope.actions").close(...)
                    end,
                },
            },
            file_ignore_patterns = {
                ".git",
                "node_modules",
            },
        },
    },
}
