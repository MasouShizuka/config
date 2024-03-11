local environment = require("utils.environment")
local icons = require("utils.icons")
local utils = require("utils")

return {
    -- {
    --     "nvim-neo-tree/neo-tree.nvim",
    --     cmd = {
    --         "Neotree",
    --     },
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --         "nvim-lua/plenary.nvim",
    --         "nvim-tree/nvim-web-devicons",
    --     },
    --     enabled = not environment.is_vscode,
    --     init = function()
    --         vim.g.neo_tree_remove_legacy_commands = true
    --     end,
    --     opts = {
    --         -- If a user has a sources list it will replace this one.
    --         -- Only sources listed here will be loaded.
    --         -- You can also add an external source by adding it's name to this list.
    --         -- The name used here must be the same name you would use in a require() call.
    --         sources = {
    --             "filesystem",
    --             -- "buffers",
    --             -- "git_status",
    --             "document_symbols",
    --         },
    --         auto_clean_after_session_restore = true, -- Automatically clean up broken neo-tree buffers saved in sessions
    --         close_if_last_window = true,             -- Close Neo-tree if it is the last window left in the tab
    --         hide_root_node = true,                   -- Hide the root node.
    --         retain_hidden_root_indent = true,        -- IF the root node is hidden, keep the indentation anyhow.
    --         -- This is needed if you use expanders because they render in the indent.
    --         popup_border_style = "rounded",          -- "double", "none", "rounded", "shadow", "single" or "solid"
    --         sort_case_insensitive = true,            -- used when sorting files and directories in the tree
    --         default_component_configs = {
    --             diagnostics = {
    --                 symbols = {
    --                     error = icons.diagnostics.Error,
    --                     hint = icons.diagnostics.Hint,
    --                     info = icons.diagnostics.Info,
    --                     warn = icons.diagnostics.Warn,
    --                 },
    --             },
    --             indent = {
    --                 with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
    --             },
    --             name = {
    --                 highlight_opened_files = true, -- Requires `enable_opened_markers = true`.
    --             },
    --             git_status = {
    --                 symbols = icons.git,
    --             },
    --         },
    --         commands = {
    --             system_open = function(state)
    --                 utils.system_open(state.tree:get_node():get_id())
    --             end,
    --             diff_files = function(state)
    --                 local node = state.tree:get_node()
    --                 local log = require("neo-tree.log")
    --                 state.clipboard = state.clipboard or {}
    --                 if diff_Node and diff_Node ~= tostring(node.id) then
    --                     local current_Diff = node.id
    --                     require("neo-tree.utils").open_file(state, diff_Node, open)
    --                     vim.cmd("vert diffs " .. current_Diff)
    --                     log.info("Diffing " .. diff_Name .. " against " .. node.name)
    --                     diff_Node = nil
    --                     current_Diff = nil
    --                     state.clipboard = {}
    --                     require("neo-tree.ui.renderer").redraw(state)
    --                 else
    --                     local existing = state.clipboard[node.id]
    --                     if existing and existing.action == "diff" then
    --                         state.clipboard[node.id] = nil
    --                         diff_Node = nil
    --                         require("neo-tree.ui.renderer").redraw(state)
    --                     else
    --                         state.clipboard[node.id] = { action = "diff", node = node }
    --                         diff_Name = state.clipboard[node.id].node.name
    --                         diff_Node = tostring(state.clipboard[node.id].node.id)
    --                         log.info("Diff source file " .. diff_Name)
    --                         require("neo-tree.ui.renderer").redraw(state)
    --                     end
    --                 end
    --             end,
    --             parent = function(state)
    --                 require("neo-tree.ui.renderer").focus_node(state, state.tree:get_node():get_parent_id())
    --             end,
    --             next_sibling = function(state)
    --                 local function index_of(array, value)
    --                     for i, v in ipairs(array) do
    --                         if v == value then
    --                             return i
    --                         end
    --                     end
    --                     return nil
    --                 end

    --                 local node = state.tree:get_node()
    --                 local siblings = state.tree:get_node(node:get_parent_id()):get_child_ids()
    --                 if not node.is_last_child then
    --                     local current_index = index_of(siblings, node.id)
    --                     local next_index = siblings[current_index + 1]
    --                     require("neo-tree.ui.renderer").focus_node(state, next_index)
    --                 end
    --             end,
    --             prev_sibling = function(state)
    --                 local function index_of(array, value)
    --                     for i, v in ipairs(array) do
    --                         if v == value then
    --                             return i
    --                         end
    --                     end
    --                     return nil
    --                 end

    --                 local node = state.tree:get_node()
    --                 local siblings = state.tree:get_node(node:get_parent_id()):get_child_ids()
    --                 local current_index = index_of(siblings, node.id)
    --                 if current_index > 1 then
    --                     local next_index = siblings[current_index - 1]
    --                     require("neo-tree.ui.renderer").focus_node(state, next_index)
    --                 end
    --             end,
    --             copy_selector = function(state)
    --                 local node = state.tree:get_node()
    --                 local filepath = node:get_id()
    --                 local filename = node.name
    --                 local modify = vim.fn.fnamemodify

    --                 local results = {
    --                     e = { val = modify(filename, ":e"), msg = "Extension only" },
    --                     f = { val = filename, msg = "Filename" },
    --                     b = { val = modify(filename, ":r"), msg = "Filename w/o extension" },
    --                     h = { val = modify(filepath, ":~"), msg = "Path relative to Home" },
    --                     r = { val = modify(filepath, ":."), msg = "Path relative to CWD" },
    --                     a = { val = filepath, msg = "Absolute path" },
    --                 }

    --                 local messages = {
    --                     { "\nChoose to copy to clipboard:\n", "Normal" },
    --                 }
    --                 for i, result in pairs(results) do
    --                     if result.val and result.val ~= "" then
    --                         vim.list_extend(messages, {
    --                             { ("%s."):format(i),           "Identifier" },
    --                             { (" %s: "):format(result.msg) },
    --                             { result.val,                  "String" },
    --                             { "\n" },
    --                         })
    --                     end
    --                 end
    --                 vim.api.nvim_echo(messages, false, {})
    --                 local result = results[vim.fn.getcharstr()]
    --                 if result and result.val and result.val ~= "" then
    --                     vim.notify(("Copied: %s"):format(result.val))
    --                     vim.fn.setreg("+", result.val)
    --                 end
    --             end,
    --         },
    --         window = {
    --             mappings = {
    --                 -- ["<space>"] = {
    --                 --     "toggle_node",
    --                 --     nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
    --                 -- },
    --                 ["<space>"] = "none",
    --                 -- ["<2-LeftMouse>"] = "open",
    --                 -- ["<cr>"] = "open",
    --                 ["l"] = "open",
    --                 -- ["<esc>"] = "cancel", -- close preview or floating neo-tree window
    --                 -- ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
    --                 -- ["l"] = "focus_preview",
    --                 -- ["S"] = "open_split",
    --                 ["S"] = "none",
    --                 ["V"] = "open_split",
    --                 -- -- ["S"] = "split_with_window_picker",
    --                 -- ["s"] = "open_vsplit",
    --                 ["s"] = "diff_files",
    --                 ["v"] = "open_vsplit",
    --                 -- -- ["s"] = "vsplit_with_window_picker",
    --                 -- ["t"] = "open_tabnew",
    --                 -- -- ["<cr>"] = "open_drop",
    --                 -- -- ["t"] = "open_tab_drop",
    --                 -- ["w"] = "open_with_window_picker",
    --                 -- ["C"] = "close_node",
    --                 ["<bs>"] = "close_all_subnodes",
    --                 -- ["z"] = "close_all_nodes",
    --                 -- -- ["Z"] = "expand_all_nodes",
    --                 ["Z"] = "expand_all_nodes",
    --                 -- ["R"] = "refresh",
    --                 -- ["a"] = {
    --                 --     "add",
    --                 --     -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
    --                 --     -- some commands may take optional config options, see `:h neo-tree-mappings` for details
    --                 --     config = {
    --                 --         show_path = "none", -- "none", "relative", "absolute"
    --                 --     },
    --                 -- },
    --                 -- ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
    --                 -- ["d"] = "delete",
    --                 -- ["r"] = "rename",
    --                 -- ["y"] = "copy_to_clipboard",
    --                 ["y"] = "copy_selector",
    --                 -- ["x"] = "cut_to_clipboard",
    --                 -- ["p"] = "paste_from_clipboard",
    --                 -- ["c"] = "copy", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
    --                 ["c"] = "copy_to_clipboard",
    --                 -- ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
    --                 -- ["e"] = "toggle_auto_expand_width",
    --                 -- ["q"] = "close_window",
    --                 -- ["?"] = "show_help",
    --                 -- ["<"] = "prev_source",
    --                 -- [">"] = "next_source",

    --                 ["o"] = "system_open",
    --                 ["h"] = "parent",
    --                 ["J"] = "next_sibling",
    --                 ["K"] = "prev_sibling",
    --             },
    --         },
    --         filesystem = {
    --             window = {
    --                 mappings = {
    --                     -- ["H"] = "toggle_hidden",
    --                     -- ["/"] = "fuzzy_finder",
    --                     -- ["D"] = "fuzzy_finder_directory",
    --                     -- --["/"] = "filter_as_you_type", -- this was the default until v1.28
    --                     -- ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
    --                     -- -- ["D"] = "fuzzy_sorter_directory",
    --                     -- ["f"] = "filter_on_submit",
    --                     -- ["<c-x>"] = "clear_filter",
    --                     -- ["<bs>"] = "navigate_up",
    --                     ["H"] = "navigate_up",
    --                     -- ["."] = "set_root",
    --                     ["L"] = "set_root",
    --                     -- ["[g"] = "prev_git_modified",
    --                     -- ["]g"] = "next_git_modified",
    --                     -- ["i"] = "show_file_details",
    --                     -- ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
    --                     -- ["oc"] = { "order_by_created", nowait = false },
    --                     -- ["od"] = { "order_by_diagnostics", nowait = false },
    --                     -- ["og"] = { "order_by_git_status", nowait = false },
    --                     -- ["om"] = { "order_by_modified", nowait = false },
    --                     -- ["on"] = { "order_by_name", nowait = false },
    --                     -- ["os"] = { "order_by_size", nowait = false },
    --                     -- ["ot"] = { "order_by_type", nowait = false },
    --                 },
    --                 fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
    --                     -- ["<down>"] = "move_cursor_down",
    --                     -- ["<C-n>"] = "move_cursor_down",
    --                     ["<C-j>"] = "move_cursor_down",
    --                     -- ["<up>"] = "move_cursor_up",
    --                     -- ["<C-p>"] = "move_cursor_up",
    --                     ["<C-k>"] = "move_cursor_up",
    --                 },
    --             },
    --             bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
    --             filtered_items = {
    --                 visible = true, -- when true, they will just be displayed differently than normal items
    --                 hide_dotfiles = true,
    --                 hide_gitignored = true,
    --                 hide_hidden = true, -- only works on Windows for hidden files/directories
    --                 hide_by_name = {
    --                     ".DS_Store",
    --                     "thumbs.db",
    --                     --"node_modules",
    --                 },
    --                 hide_by_pattern = { -- uses glob style patterns
    --                     --"*.meta",
    --                     --"*/src/*/tsconfig.json"
    --                 },
    --                 always_show = { -- remains visible even if other settings would normally hide it
    --                     --".gitignored",
    --                 },
    --                 never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
    --                     --".DS_Store",
    --                     --"thumbs.db"
    --                 },
    --                 never_show_by_pattern = { -- uses glob style patterns
    --                     --".null-ls_*",
    --                 },
    --             },
    --             follow_current_file = {
    --                 enabled = true,            -- This will find and focus the file in the active buffer every time
    --                 --               -- the current file is changed while the tree is open.
    --                 leave_dirs_open = true,    -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
    --             },
    --             use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
    --             -- instead of relying on nvim autocmd events.
    --         },
    --     },
    -- },

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

                    vim.keymap.set("n", "q", api.tree.close, opts("Close"))
                    vim.keymap.set("n", "<c-r>", api.tree.reload, opts("Refresh"))
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
                    vim.keymap.set("n", "H", api.tree.change_root_to_parent, opts("Up"))
                    vim.keymap.set("n", "<c-f>", api.tree.search_node, opts("Search"))
                    vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
                    vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
                    vim.keymap.set("n", "Ti", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
                    vim.keymap.set("n", "Tc", api.tree.toggle_git_clean_filter, opts("Toggle Git Clean"))
                    vim.keymap.set("n", "Tb", api.tree.toggle_no_buffer_filter, opts("Toggle No Buffer"))
                    vim.keymap.set("n", "Tu", api.tree.toggle_custom_filter, opts("Toggle Custom"))
                    vim.keymap.set("n", "Th", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
                    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))

                    vim.keymap.set("n", "Ts", cycle_sort, opts("Cycle Sort"))

                    vim.keymap.set("n", "a", api.fs.create, opts("Create"))
                    -- vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
                    -- vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
                    -- vim.keymap.set("n", "d", function()
                    --     local node = api.tree.get_node_under_cursor()
                    --     vim.ui.input({ prompt = ("Remove %s? [y/N]"):format(node.name) }, function(input)
                    --         if input == "y" then
                    --             api.fs.remove()
                    --             api.tree.reload()
                    --         end
                    --     end)
                    -- end, opts("Delete"))
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
                    vim.keymap.set("n", "R", api.fs.rename_sub, opts("Rename: Omit Filename"))
                    -- vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
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
                    -- vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
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
                            b = { val = modify(name, ":r"), msg = "Filename w/o extension" },
                            h = { val = modify(absolute_path, ":~"), msg = "Path relative to Home" },
                            r = { val = modify(absolute_path, ":."), msg = "Path relative to CWD" },
                            a = { val = absolute_path, msg = "Absolute path" },
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
                    vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
                    vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
                    vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
                    vim.keymap.set("n", "V", api.node.open.horizontal, opts("Open: Horizontal Split"))
                    -- vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
                    vim.keymap.set("n", "t", function()
                        vim.g.is_opening_tab = true

                        local node = api.tree.get_node_under_cursor()
                        api.node.open.tab(node)
                        vim.cmd.tabprev()

                        vim.g.is_opening_tab = false
                    end, opts("Open: New Tab"))
                    vim.keymap.set("n", "<tab>", api.node.open.preview, opts("Open Preview"))
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
                        vim.cmd("normal! j")
                    end, opts("Toggle Bookmark Down"))
                    vim.keymap.set("n", "K", function()
                        api.marks.toggle()
                        vim.cmd("normal! k")
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
                git = {
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
