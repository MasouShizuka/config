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
            { "<c-p>",      function() require("telescope.builtin").find_files({ hidden = true, no_ignore = true }) end, desc = "Find files",      mode = "n" },
            { "<leader>/",  function() require("telescope.builtin").live_grep() end,                                     desc = "Live grep",       mode = "n" },
            { "<leader>tb", function() require("telescope.builtin").buffers() end,                                       desc = "Buffers",         mode = "n" },
            { "<leader>to", function() require("telescope.builtin").oldfiles() end,                                      desc = "Old files",       mode = "n" },
            { "<leader>t:", function() require("telescope.builtin").command_history() end,                               desc = "Command history", mode = "n" },
            { "<leader>t/", function() require("telescope.builtin").search_history() end,                                desc = "Search history",  mode = "n" },
            { "<leader>th", function() require("telescope.builtin").help_tags() end,                                     desc = "Help tags",       mode = "n" },
            { "<leader>tv", function() require("telescope.builtin").vim_options() end,                                   desc = "Vim options",     mode = "n" },
            { "<leader>tr", function() require("telescope.builtin").registers() end,                                     desc = "Registers",       mode = "n" },
            { "<leader>tn", function() require("telescope").extensions.notify.notify() end,                              desc = "Notify",          mode = "n" },
        },
        opts = function()
            local actions = require("telescope.actions")

            local function multiopen(prompt_bufnr, method)
                local edit_file_cmd_map = {
                    vertical = "vsplit",
                    horizontal = "split",
                    tab = "tabnew",
                    default = "edit",
                }
                local edit_buf_cmd_map = {
                    vertical = "vert sbuffer",
                    horizontal = "sbuffer",
                    tab = "tab sbuffer",
                    default = "buffer",
                }
                local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                local multi_selection = picker:get_multi_selection()

                if #multi_selection > 1 then
                    require("telescope.pickers").on_close_prompt(prompt_bufnr)
                    pcall(vim.api.nvim_set_current_win, picker.original_win_id)

                    for i, entry in ipairs(multi_selection) do
                        local filename, row, col

                        if entry.path or entry.filename then
                            filename = entry.path or entry.filename

                            row = entry.row or entry.lnum
                            col = vim.F.if_nil(entry.col, 1)
                        elseif not entry.bufnr then
                            local value = entry.value
                            if not value then
                                return
                            end

                            if type(value) == "table" then
                                value = entry.display
                            end

                            local sections = vim.split(value, ":")

                            filename = sections[1]
                            row = tonumber(sections[2])
                            col = tonumber(sections[3])
                        end

                        local entry_bufnr = entry.bufnr

                        if entry_bufnr then
                            if not vim.api.nvim_get_option_value("buflisted", { buf = entry_bufnr }) then
                                vim.api.nvim_set_option_value("buflisted", true, { buf = entry_bufnr })
                            end
                            local command = edit_buf_cmd_map[method]
                            pcall(vim.cmd, string.format("%s %s", command, vim.api.nvim_buf_get_name(entry_bufnr)))
                        else
                            local command = edit_file_cmd_map[method]
                            if vim.api.nvim_buf_get_name(0) ~= filename or command ~= "edit" then
                                filename = require("plenary.path"):new(vim.fn.fnameescape(filename)):normalize(vim.loop.cwd())
                                pcall(vim.cmd, string.format("%s %s", command, filename))
                            end
                        end

                        if row and col then
                            pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
                        end
                    end
                else
                    actions["select_" .. method](prompt_bufnr)
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
                            ["<c-t>"] = function(prompt_bufnr) multiopen(prompt_bufnr, "tab") end,
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
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        -- 搜索 hidden、.gitignore 文件
                        "--hidden",
                        "--no-ignore",
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
