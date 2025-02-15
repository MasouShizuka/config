local environment = require("utils.environment")
local icons = require("utils.icons")
local utils = require("utils")

return {
    {
        "nvim-tree/nvim-tree.lua",
        cmd = {
            "NvimTreeOpen",
            "NvimTreeClose",
            "NvimTreeToggle",
            "NvimTreeFocus",
            "NvimTreeRefresh",
            "NvimTreeFindFile",
            "NvimTreeFindFileToggle",
            "NvimTreeClipboard",
            "NvimTreeResize",
            "NvimTreeCollapse",
            "NvimTreeCollapseKeepBuffers",
            "NvimTreeGenerateOnAttach",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        init = function()
            -- disable netrw at the very start of your init.lua
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        opts = function()
            local api = require("nvim-tree.api")

            local SORT_METHODS = {
                "name",
                "case_sensitive",
                "modification_time",
                "extension",
                "suffix",
                "filetype",
            }
            local sort_current = 1

            local function cycle_sort()
                if sort_current >= #SORT_METHODS then
                    sort_current = 1
                else
                    sort_current = sort_current + 1
                end
                api.tree.reload()
                vim.notify(("Sort by %s"):format(SORT_METHODS[sort_current]), vim.log.levels.INFO, { title = "NvimTree" })
            end

            local function sorter()
                return SORT_METHODS[sort_current]
            end

            return {
                on_attach = function(bufnr)
                    local function opts(desc)
                        return { buffer = bufnr, desc = "nvim-tree: " .. desc, nowait = true, silent = true }
                    end

                    vim.keymap.set("n", "<2-rightmouse>", api.tree.change_root_to_node, opts("CD"))
                    vim.keymap.set("n", "L", function()
                        local node = api.tree.get_node_under_cursor()
                        if node.type ~= "directory" then
                            api.node.navigate.parent()
                            api.tree.change_root_to_node()
                            vim.api.nvim_set_current_dir(node.parent.absolute_path)
                        else
                            api.tree.change_root_to_node()
                            vim.api.nvim_set_current_dir(node.absolute_path)
                        end
                    end, opts("CD"))
                    vim.keymap.set("n", "H", function()
                        api.tree.change_root_to_parent()
                        vim.api.nvim_set_current_dir(vim.fn.fnamemodify(vim.fn.getcwd(-1, -1), ":h"))
                    end, opts("Up"))
                    vim.keymap.set("n", "<c-f>", api.tree.search_node, opts("Search"))
                    vim.keymap.set("n", "zm", api.tree.collapse_all, opts("Collapse"))
                    vim.keymap.set("n", "zr", api.tree.expand_all, opts("Expand All"))
                    vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
                    vim.keymap.set("n", "Ti", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
                    vim.keymap.set("n", "Tc", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
                    vim.keymap.set("n", "Tb", api.tree.toggle_no_buffer_filter, opts("Toggle No Buffer"))
                    vim.keymap.set("n", "Tu", api.tree.toggle_custom_filter, opts("Toggle Custom"))
                    vim.keymap.set("n", "Th", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
                    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))

                    vim.keymap.set("n", "Ts", cycle_sort, opts("Cycle Sort"))

                    vim.keymap.set("n", "a", api.fs.create, opts("Create"))
                    -- vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
                    vim.keymap.set("n", "d", function()
                        local marks = api.marks.list()
                        if #marks == 0 then
                            marks[#marks + 1] = api.tree.get_node_under_cursor()
                        end
                        vim.ui.input({ prompt = ("Remove %s files? [y/N]"):format(#marks) }, function(input)
                            if input == "y" then
                                for _, node in ipairs(marks) do
                                    api.fs.remove(node)
                                end
                                api.marks.clear()
                                api.tree.reload()
                            end
                        end)
                    end, opts("Delete File(s)"))
                    vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
                    vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
                    vim.keymap.set("n", "u", api.fs.rename_full, opts("Rename: Full Path"))
                    vim.keymap.set("n", "x", function()
                        local marks = api.marks.list()
                        if #marks == 0 then
                            marks[#marks + 1] = api.tree.get_node_under_cursor()
                        end
                        for _, node in pairs(marks) do
                            api.fs.cut(node)
                        end
                        api.marks.clear()
                        api.tree.reload()
                    end, opts("Cut File(s)"))
                    vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                    vim.keymap.set("n", "c", function()
                        local marks = api.marks.list()
                        if #marks == 0 then
                            marks[#marks + 1] = api.tree.get_node_under_cursor()
                        end
                        for _, node in pairs(marks) do
                            api.fs.copy.node(node)
                        end
                        api.marks.clear()
                        api.tree.reload()
                    end, opts("Copy File(s)"))
                    vim.keymap.set("n", "y", function()
                        local node = api.tree.get_node_under_cursor()
                        local absolute_path = node.absolute_path
                        local extension = node.extension
                        local name = node.name
                        local modify = vim.fn.fnamemodify

                        local results = {
                            e = { val = extension, msg = "Extension only" },
                            f = { val = name, msg = "Filename" },
                            w = { val = modify(name, ":r"), msg = "Filename w/o extension" },
                            h = { val = modify(absolute_path, ":~"), msg = "Path relative to Home" },
                            r = { val = modify(absolute_path, ":."), msg = "Path relative to CWD" },
                            y = { val = absolute_path, msg = "Absolute path" },
                        }

                        local messages = {
                            { "\nChoose to copy to clipboard:\n", "Normal" },
                        }
                        for i, result in pairs(results) do
                            if result.val and result.val ~= "" then
                                vim.list_extend(messages, {
                                    { ("%s."):format(i),           "Identifier" },
                                    { (" %s: "):format(result.msg) },
                                    { result.val,                  "String" },
                                    { "\n" },
                                })
                            end
                        end
                        vim.api.nvim_echo(messages, false, {})
                        local result = results[vim.fn.getcharstr()]
                        if result and result.val and result.val ~= "" then
                            vim.notify(("Copied: %s"):format(result.val), vim.log.levels.INFO, { title = "NvimTree" })
                            vim.fn.setreg("+", result.val)
                        end
                    end, opts("Copy Info"))
                    vim.keymap.set("n", "s", function()
                        local marks = api.marks.list()
                        if #marks ~= 2 then
                            vim.notify("Diff requires specifying 2 files", vim.log.levels.WARN, { title = "NvimTree" })
                            return
                        end

                        local node1 = marks[1]
                        local node2 = marks[2]
                        api.node.open.tab(node1)
                        vim.cmd.vnew()
                        vim.cmd.edit(vim.fn.fnamemodify(node2.absolute_path, ":."))
                        utils.diffthis()

                        api.marks.clear()
                        api.tree.reload()
                    end, opts("Diff 2 Files"))

                    vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "<cr>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "<2-leftmouse>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
                    vim.keymap.set("n", "V", api.node.open.horizontal, opts("Open: Horizontal Split"))
                    vim.keymap.set("n", "t", function()
                        vim.g.is_opening_tab = true

                        local marks = api.marks.list()
                        if #marks == 0 then
                            marks[#marks + 1] = api.tree.get_node_under_cursor()
                        end
                        for _, node in pairs(marks) do
                            api.node.open.tab(node)
                            vim.cmd.tabprev()
                        end
                        api.marks.clear()
                        api.tree.reload()

                        vim.g.is_opening_tab = false
                    end, opts("Open: New Tab"))
                    vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
                    vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
                    vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
                    vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
                    vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
                    vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
                    vim.keymap.set("n", "h", api.node.navigate.parent, opts("Parent Directory"))
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
                    vim.keymap.set("n", "M", api.marks.clear, opts("Clear Bookmark"))
                    vim.keymap.set("n", "J", function()
                        api.marks.toggle()
                        vim.cmd.normal({ "j", bang = true })
                    end, opts("Toggle Bookmark Down"))
                    vim.keymap.set("n", "K", function()
                        api.marks.toggle()
                        vim.cmd.normal({ "k", bang = true })
                    end, opts("Toggle Bookmark Up"))
                end,
                disable_netrw = true,
                sync_root_with_cwd = true,
                select_prompts = true,
                sort = {
                    sorter = sorter,
                },
                view = {
                    centralize_selection = true,
                    signcolumn = "no",
                    width = "20%",
                },
                renderer = {
                    root_folder_label = false,
                    highlight_opened_files = "all",
                    indent_markers = {
                        enable = true,
                    },
                    icons = {
                        git_placement = "after",
                        diagnostics_placement = "after",
                        bookmarks_placement = "before",
                        glyphs = {
                            git = {
                                unstaged = icons.git.unstaged,
                                staged = icons.git.staged,
                                unmerged = icons.git.conflict,
                                renamed = icons.git.renamed,
                                untracked = icons.git.untracked,
                                deleted = icons.git.deleted,
                                ignored = icons.git.ignored,
                            },
                        },
                    },
                },
                update_focused_file = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                    icons = {
                        error = icons.diagnostics.Error,
                        hint = icons.diagnostics.Hint,
                        info = icons.diagnostics.Info,
                        warning = icons.diagnostics.Warn,
                    },
                },
                filters = {
                    git_ignored = false,
                },
                live_filter = {
                    always_show_folders = false,
                },
                ui = {
                    confirm = {
                        remove = false,
                        trash = false,
                    },
                },
            }
        end,
    },
}
