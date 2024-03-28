local environment = require("utils.environment")
local path = require("utils.path")

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
        enabled = not environment.is_vscode,
        init = function()
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
                    mode = "n",
                    ["<leader>t"] = {
                        name = "+telescope",
                    },
                })
            end
        end,
        keys = {
            { "<c-p>",      function() require("telescope.builtin").find_files() end,       desc = "Find files",      mode = "n" },
            { "<leader>/",  function() require("telescope.builtin").live_grep() end,        desc = "Live grep",       mode = "n" },
            { "<leader>tb", function() require("telescope.builtin").buffers() end,          desc = "Buffers",         mode = "n" },
            { "<leader>to", function() require("telescope.builtin").oldfiles() end,         desc = "Old files",       mode = "n" },
            { "<leader>t:", function() require("telescope.builtin").command_history() end,  desc = "Command history", mode = "n" },
            { "<leader>t/", function() require("telescope.builtin").search_history() end,   desc = "Search history",  mode = "n" },
            { "<leader>th", function() require("telescope.builtin").help_tags() end,        desc = "Help tags",       mode = "n" },
            { "<leader>tv", function() require("telescope.builtin").vim_options() end,      desc = "Vim options",     mode = "n" },
            { "<leader>tr", function() require("telescope.builtin").registers() end,        desc = "Registers",       mode = "n" },
            { "<leader>tn", function() require("telescope").extensions.notify.notify() end, desc = "Notify",          mode = "n" },
        },
        opts = function()
            local actions = require("telescope.actions")

            local select_one_or_multi_tab = function(prompt_bufnr)
                local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                local multi = picker:get_multi_selection()
                if not vim.tbl_isempty(multi) then
                    require("telescope.actions").close(prompt_bufnr)
                    for _, j in pairs(multi) do
                        if j.path ~= nil then
                            vim.cmd(string.format("%s %s", "tabnew", j.path))
                        end
                    end
                else
                    require("telescope.actions").select_tab(prompt_bufnr)
                end
            end

            return {
                defaults = {
                    sorting_strategy = "ascending",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.5,
                        },
                    },
                    mappings = {
                        i = {
                            ["<c-j>"] = actions.move_selection_next,
                            ["<c-k>"] = actions.move_selection_previous,
                            ["<down>"] = actions.move_selection_next,
                            ["<up>"] = actions.move_selection_previous,
                            ["<s-down>"] = actions.toggle_selection + actions.move_selection_next,
                            ["<s-up>"] = actions.toggle_selection + actions.move_selection_previous,
                            ["<c-a>"] = actions.toggle_all,
                            ["<c-u>"] = actions.preview_scrolling_up,
                            ["<c-d>"] = actions.preview_scrolling_down,
                            ["<c-h>"] = actions.preview_scrolling_left,
                            ["<c-l>"] = actions.preview_scrolling_right,
                            ["<pageup>"] = actions.results_scrolling_up,
                            ["<pagedown>"] = actions.results_scrolling_down,
                            ["<cr>"] = actions.select_default,
                            ["<c-x>"] = actions.select_horizontal,
                            ["<c-v>"] = actions.select_vertical,
                            ["<c-t>"] = select_one_or_multi_tab,
                            ["<c-w>"] = actions.close,
                            ["<c-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<c-n>"] = actions.cycle_history_next,
                            ["<c-p>"] = actions.cycle_history_prev,
                            ["<c-/>"] = actions.which_key,
                        },
                    },
                    history = {
                        path = path.data_path .. "/lazy/telescope.nvim/telescope_history",
                    },
                    file_ignore_patterns = {
                        "%.git",
                        "node_modules",
                    },
                },
            }
        end,
    },
}
