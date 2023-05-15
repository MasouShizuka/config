local variables = require("config.variables")

return {
    {
        "nvim-tree/nvim-tree.lua",
        config = function(_, opts)
            require("nvim-tree").setup(opts)

            -- 确保 git 命令能够成功执行
            if variables.is_windows then
                vim.opt.shell = "cmd"
                vim.opt.shellcmdflag = "/s /c"
                vim.opt.shellxescape = "("
            end

            -- 最后的窗口为 NvimTree 时自动关闭
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
                pattern = "NvimTree_*",
                callback = function()
                    local layout = vim.api.nvim_call_function("winlayout", {})
                    if
                        layout[1] == "leaf"
                        and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
                        and layout[3] == nil
                    then
                        vim.api.nvim_command("confirm quit")
                    end
                end,
            })
        end,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        init = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        lazy = true,
        opts = function()
            local api = require("nvim-tree.api")

            local SORT_METHODS = {
                "name",
                "case_sensitive",
                "modification_time",
                "extension",
            }
            local sort_current = 1

            local cycle_sort = function()
                if sort_current >= #SORT_METHODS then
                    sort_current = 1
                else
                    sort_current = sort_current + 1
                end
                api.tree.reload()
                vim.notify(string.format("Sort by %s", SORT_METHODS[sort_current]))
            end

            local sort_by = function()
                return SORT_METHODS[sort_current]
            end

            return {
                sort_by = sort_by,
                on_attach = function(bufnr)
                    local function opts(desc)
                        return { desc = "nvim-tree: " .. desc, buffer = bufnr, silent = true, nowait = true }
                    end

                    vim.keymap.set("n", "T", cycle_sort, opts("Cycle Sort"))

                    vim.keymap.set("n", "q", api.tree.close, opts("Close"))
                    vim.keymap.set("n", "<c-r>", api.tree.reload, opts("Refresh"))
                    -- vim.keymap.set("n", "L", api.tree.change_root_to_node, opts("CD"))
                    vim.keymap.set("n", "L", function()
                        local node = api.tree.get_node_under_cursor()
                        if node.type ~= "directory" then
                            api.node.navigate.parent()
                            api.tree.change_root_to_node()
                        else
                            api.tree.change_root_to_node()
                        end
                    end, opts("CD"))
                    vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
                    vim.keymap.set("n", "h", api.tree.change_root_to_parent, opts("Up"))
                    vim.keymap.set("n", "<c-f>", api.tree.search_node, opts("Search"))
                    vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
                    vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
                    vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
                    vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
                    vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle No Buffer"))
                    vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
                    vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
                    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))

                    -- vim.keymap.set("n", "a", api.fs.create, opts("Create"))
                    vim.keymap.set("n", "a", function()
                        api.fs.create()
                        api.events.subscribe(api.events.Event.FileCreated, function(file)
                            vim.cmd.tabedit(file.fname)
                        end)
                    end, opts("Create"))
                    -- vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
                    -- vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
                    vim.keymap.set("n", "d", function()
                        local node = api.tree.get_node_under_cursor()
                        vim.ui.input({ prompt = string.format("Remove %s? [y/N]", node.name) }, function(input)
                            if input == "y" then
                                api.fs.remove()
                                api.tree.reload()
                            end
                        end)
                    end, opts("Delete"))
                    vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
                    vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
                    vim.keymap.set("n", "R", api.fs.rename_sub, opts("Rename: Omit Filename"))
                    vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
                    vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                    vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
                    vim.keymap.set("n", "Y", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
                    vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))

                    vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "<cr>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
                    -- vim.keymap.set("n", "<c-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
                    vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
                    vim.keymap.set("n", "s", api.node.open.vertical, opts("Open: Vertical Split"))
                    vim.keymap.set("n", "S", api.node.open.horizontal, opts("Open: Horizontal Split"))
                    -- vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
                    vim.keymap.set("n", "t", function()
                        local api = require("nvim-tree.api")
                        local node = api.tree.get_node_under_cursor()
                        vim.cmd("wincmd l")
                        api.node.open.tab(node)
                    end, opts("Open: New Tab"))
                    vim.keymap.set("n", "<tab>", api.node.open.preview, opts("Open Preview"))
                    vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
                    vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
                    vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
                    vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
                    vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
                    vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
                    -- vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
                    -- vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
                    vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
                    vim.keymap.set("n", "<bs>", api.node.navigate.parent_close, opts("Close Directory"))
                    vim.keymap.set("n", "i", api.node.show_info_popup, opts("Info"))
                    vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
                    vim.keymap.set("n", "o", api.node.run.system, opts("Run System"))

                    vim.keymap.set("n", "f", function(...)
                        api.tree.expand_all(...)
                        api.live_filter.start(...)
                    end, opts("Filter"))
                    vim.keymap.set("n", "F", function(...)
                        api.live_filter.clear(...)
                        api.tree.collapse_all(...)
                    end, opts("Clean Filter"))

                    vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
                    vim.keymap.set("n", "Mm", api.marks.bulk.move, opts("Move Bookmarked"))
                    vim.keymap.set("n", "J", function()
                        api.marks.toggle()
                        vim.cmd.normal("j")
                    end, opts("Toggle Bookmark Down"))
                    vim.keymap.set("n", "K", function()
                        api.marks.toggle()
                        vim.cmd.normal("k")
                    end, opts("Toggle Bookmark Up"))
                    vim.keymap.set("n", "Mc", function()
                        local marks = api.marks.list()
                        if #marks == 0 then
                            table.insert(marks, api.tree.get_node_under_cursor())
                        end
                        for _, node in pairs(marks) do
                            api.fs.copy.node(node)
                        end
                        api.marks.clear()
                        api.tree.reload()
                    end, opts("Copy File(s)"))
                    vim.keymap.set("n", "Mx", function()
                        local marks = api.marks.list()
                        if #marks == 0 then
                            table.insert(marks, api.tree.get_node_under_cursor())
                        end
                        for _, node in pairs(marks) do
                            api.fs.cut(node)
                        end
                        api.marks.clear()
                        api.tree.reload()
                    end, opts("Cut File(s)"))
                    vim.keymap.set("n", "Md", function()
                        local marks = api.marks.list()
                        if #marks == 0 then
                            table.insert(marks, api.tree.get_node_under_cursor())
                        end
                        vim.ui.input({ prompt = string.format("Remove %s files? [y/N]", #marks) }, function(input)
                            if input == "y" then
                                for _, node in ipairs(marks) do
                                    api.fs.remove(node)
                                end
                                api.marks.clear()
                                api.tree.reload()
                            end
                        end)
                    end, opts("Remove File(s)"))
                end,
                select_prompts = true,
                view = {
                    centralize_selection = true,
                    width = "20%",
                },
                renderer = {
                    highlight_opened_files = "all",
                    highlight_modified = "all",
                },
                update_focused_file = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                    icons = {
                        error = variables.icons.diagnostics.Error,
                        hint = variables.icons.diagnostics.Hint,
                        info = variables.icons.diagnostics.Info,
                        warning = variables.icons.diagnostics.Warn,
                    },
                },
                git = {
                    ignore = false,
                },
                modified = {
                    enable = true,
                },
                live_filter = {
                    always_show_folders = false,
                },
                tab = {
                    sync = {
                        open = true,
                        close = true,
                    },
                },
                ui = {
                    confirm = {
                        remove = false,
                        trash = false,
                    },
                },
            }
        end,
        version = "*",
    },
}
