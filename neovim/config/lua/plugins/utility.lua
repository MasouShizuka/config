local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        "Aasim-A/scrollEOF.nvim",
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        opts = function()
            return {
                -- List of filetypes to disable scrollEOF for.
                disabled_filetypes = require("utils.filetype").skip_filetype_list,
            }
        end,
    },

    {
        "chrisgrieser/nvim-early-retirement",
        event = {
            "User IceLoad",
        },
        opts = {
            -- If a buffer has been inactive for this many minutes, close it.
            retirementAgeMins = 5,
        },
    },

    {
        "delphinus/cellwidths.nvim",
        cmd = {
            "CellWidthsAdd",
            "CellWidthsDelete",
            "CellWidthsLoad",
            "CellWidthsRemove",
        },
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        opts = {
            name = "default",
            -- name = "empty",         -- 空の設定です。
            -- name = "default",       -- vim-ambiwidth のデフォルトです。
            -- name = "cica",          -- vim-ambiwidth の Cica 用設定です。
            -- name = "sfmono_square", -- SF Mono Square 用設定です。
        },
    },

    {
        "folke/noice.nvim",
        cmd = {
            "Noice",
        },
        enabled = not environment.is_vscode,
        event = {
            "CmdlineEnter",
            "LspAttach",
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        opts = {
            messages = {
                view_search = false, -- view for search count messages. Set to `false` to disable
            },
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always "notify" and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = false,
            },
            lsp = {
                override = {
                    -- override the default lsp markdown formatter with Noice
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    -- override the lsp markdown formatter with Noice
                    ["vim.lsp.util.stylize_markdown"] = true,
                    -- override cmp documentation with Noice (needs the other options to work)
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                command_palette = true, -- position the cmdline and popupmenu together
                lsp_doc_border = true,  -- add a border to hover docs and signature help
            },
            views = {
                mini = {
                    win_options = {
                        winblend = 0,
                    },
                },
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                        },
                    },
                    view = "mini",
                },
            },
        },
    },
    -- NOTE: 需要安装 ripgrep
    {
        "folke/snacks.nvim",
        enabled = not environment.is_vscode,
        init = function()
            local utils = require("utils")
            utils.create_once_autocmd("User", {
                callback = function()
                    local snacks = require("snacks")

                    if utils.is_available("which-key.nvim") then
                        require("which-key").add({
                            {
                                mode = "n",
                                { "<leader>t",  group = "picker" },
                                { "<leader>tg", group = "picker git" },
                                { "<leader>lg", group = "picker lsp goto" },
                                { "<leader>T",  group = "command line tool", mode = "n" },
                            },
                        })
                    end

                    -- Setup some globals for debugging (lazy-loaded)
                    _G.dd = function(...)
                        snacks.debug.inspect(...)
                    end
                    _G.bt = function()
                        snacks.debug.backtrace()
                    end
                    vim.print = _G.dd -- Override print to use snacks for `:=` command

                    local cli_opts = {
                        win = {
                            on_buf = function(self)
                                -- 禁用 cellwidth 设置
                                if utils.is_available("cellwidths.nvim") and package.loaded["cellwidths"] then
                                    vim.api.nvim_command("CellWidthsLoad empty")
                                end
                            end,
                            on_close = function()
                                -- 恢复 cellwidth 设置
                                if utils.is_available("cellwidths.nvim") and package.loaded["cellwidths"] then
                                    vim.api.nvim_command("CellWidthsLoad default")
                                end
                            end,
                        },
                    }
                    vim.keymap.set("n", "<leader>Tl", function() snacks.lazygit(cli_opts) end, { desc = "Open lazygit", silent = true })
                    vim.keymap.set("n", "<leader>Ty", function() snacks.terminal("yazi", cli_opts) end, { desc = "Open yazi", silent = true })

                    snacks.toggle.diagnostics():map("<leader>ctd")
                    -- snacks.toggle.indent():map("<leader>cti")
                    -- snacks.toggle.scroll():map("<leader>ctS")
                    snacks.toggle.words():map("<leader>ctW")
                end,
                desc = "Snacks init",
                pattern = "IceLoad",
            })

            -- 当直接打开一个大文件时，需要手动执行
            if vim.fn.argc(-1) > 0 then
                local function load_bigfile(args)
                    local snacks = require("snacks")

                    local opts = snacks.config.get("bigfile", { notify = true })
                    if opts.notify then
                        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":p:~:.")
                        snacks.notify.warn({
                            ("Big file detected `%s`."):format(path),
                            "Some Neovim features have been **disabled**.",
                        }, { title = "Big File" })
                    end
                    vim.api.nvim_buf_call(args.buf, function()
                        opts.setup({
                            buf = args.buf,
                            ft = vim.filetype.match({ buf = args.buf }) or "",
                        })
                    end)
                end

                utils.create_once_autocmd("BufReadPre", {
                    callback = function(ev)
                        if not utils.is_bigfile(ev.buf) then
                            return
                        end

                        load_bigfile(ev)
                    end,
                    desc = "Disable bigfile features when running nvim with file argument",
                })
                utils.create_once_autocmd("BufReadPost", {
                    callback = function(ev)
                        if not utils.is_longfile(ev.buf) then
                            return
                        end

                        load_bigfile(ev)
                    end,
                    desc = "Disable bigfile features when running nvim with file argument",
                })
            end
        end,
        keys = {
            { "ii",         mode = { "x", "o" } },
            { "ai",         mode = { "x", "o" } },
            { "[i",         mode = { "n", "x", "o" } },
            { "]i",         mode = { "n", "x", "o" } },

            { "<leader>ta", function() require("snacks").picker.autocmds() end, desc = "Autocmds", mode = "n" },
            { "<leader>tb", function() require("snacks").picker.buffers() end,  desc = "Buffers",  mode = "n" },
            {
                "<leader>tc",
                function()
                    vim.api.nvim_exec_autocmds("User", { pattern = "ColorschemePre" })
                    require("snacks").picker.colorschemes()
                end,
                desc = "Neovim colorschemes with live preview",
                mode = "n",
            },
            { "<leader>t:",  function() require("snacks").picker.command_history() end,       desc = "Neovim command history",                      mode = "n" },
            { "<c-s-p>",     function() require("snacks").picker.commands() end,              desc = "Neovim commands",                             mode = "n" },
            { "<leader>tD",  function() require("snacks").picker.diagnostics() end,           desc = "Diagnostics",                                 mode = "n" },
            { "<leader>td",  function() require("snacks").picker.diagnostics_buffer() end,    desc = "Buffer Diagnostics",                          mode = "n" },
            { "<leader>tgb", function() require("snacks").picker.git_branches() end,          desc = "Git Branches",                                mode = "n" },
            { "<leader>tgd", function() require("snacks").picker.git_diff() end,              desc = "Git Diff (Hunks)",                            mode = "n" },
            { "<leader>tgg", function() require("snacks").picker.git_files() end,             desc = "Find git files",                              mode = "n" },
            { "<leader>tg/", function() require("snacks").picker.git_grep() end,              desc = "Grep in git files",                           mode = "n" },
            { "<leader>tgo", function() require("snacks").picker.git_log() end,               desc = "Git log" },
            { "<leader>tgf", function() require("snacks").picker.git_log_file() end,          desc = "Git log file",                                mode = "n" },
            { "<leader>tgl", function() require("snacks").picker.git_log_line() end,          desc = "Git log line",                                mode = "n" },
            { "<leader>tgS", function() require("snacks").picker.git_stash() end,             desc = "Git Stash",                                   mode = "n" },
            { "<leader>tgs", function() require("snacks").picker.git_status() end,            desc = "Git Status",                                  mode = "n" },
            { "<leader>/",   function() require("snacks").picker.grep() end,                  desc = "Grep",                                        mode = "n" },
            { "<leader>tB",  function() require("snacks").picker.grep_buffers() end,          desc = "Grep Open Buffers",                           mode = "n" },
            { "<leader>tw",  function() require("snacks").picker.grep_word() end,             desc = "Visual selection or word",                    mode = { "n", "x" } },
            { "<leader>th",  function() require("snacks").picker.help() end,                  desc = "Neovim help tags",                            mode = "n" },
            { "<leader>tH",  function() require("snacks").picker.highlights() end,            desc = "Highlights",                                  mode = "n" },
            { "<leader>ti",  function() require("snacks").picker.icons() end,                 desc = "Icons",                                       mode = "n" },
            { "<leader>tj",  function() require("snacks").picker.jumps() end,                 desc = "Jumps",                                       mode = "n" },
            { "<leader>tk",  function() require("snacks").picker.keymaps() end,               desc = "Keymaps",                                     mode = "n" },
            { "<leader>tz",  function() require("snacks").picker.lazy() end,                  desc = "Search for a lazy.nvim plugin spec",          mode = "n" },
            { "<leader>tl",  function() require("snacks").picker.lines() end,                 desc = "Search lines in the current buffer",          mode = "n" },
            { "<leader>tL",  function() require("snacks").picker.loclist() end,               desc = "Loclist",                                     mode = "n" },
            { "<leader>lgD", function() require("snacks").picker.lsp_declarations() end,      desc = "LSP declarations",                            mode = "n" },
            { "<leader>lgd", function() require("snacks").picker.lsp_definitions() end,       desc = "LSP definitions",                             mode = "n" },
            { "<leader>lgi", function() require("snacks").picker.lsp_implementations() end,   desc = "LSP implementations",                         mode = "n" },
            { "<leader>lgr", function() require("snacks").picker.lsp_references() end,        desc = "LSP references",                              mode = "n" },
            { "<leader>ls",  function() require("snacks").picker.lsp_symbols() end,           desc = "LSP document symbols",                        mode = "n" },
            { "<leader>lgy", function() require("snacks").picker.lsp_type_definitions() end,  desc = "LSP type definitions",                        mode = "n" },
            { "<leader>lS",  function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP workspace symbols",                       mode = "n" },
            { "<leader>tm",  function() require("snacks").picker.man() end,                   desc = "Man Pages",                                   mode = "n" },
            { "<leader>t'",  function() require("snacks").picker.marks() end,                 desc = "Marks",                                       mode = "n" },
            { "<leader>tn",  function() require("snacks").picker.notifications() end,         desc = "Notification History",                        mode = "n" },
            { "<leader>tp",  function() require("snacks").picker.pickers() end,               desc = "List all available sources",                  mode = "n" },
            { "<leader>tq",  function() require("snacks").picker.qflist() end,                desc = "Quickfix list",                               mode = "n" },
            { "<leader>tr",  function() require("snacks").picker.recent() end,                desc = "Find recent files",                           mode = "n" },
            { '<leader>t"',  function() require("snacks").picker.registers() end,             desc = "Neovim registers",                            mode = "n" },
            { "<leader>tR",  function() require("snacks").picker.resume() end,                desc = "Special picker that resumes the last picker", mode = "n" },
            { "<leader>t/",  function() require("snacks").picker.search_history() end,        desc = "Neovim search history",                       mode = "n" },
            { "<c-p>",       function() require("snacks").picker.smart() end,                 desc = "Smart Find Files",                            mode = "n" },
            { "<leader>ts",  function() require("snacks").picker.spelling() end,              desc = "Spelling",                                    mode = "n" },
            { "<leader>tt",  function() require("snacks").picker.treesitter() end,            desc = "Treesitter",                                  mode = "n" },
            { "<leader>tu",  function() require("snacks").picker.undo() end,                  desc = "Undo History",                                mode = "n" },

            { "<s-f2>",      function() require("snacks").rename.rename_file() end,           desc = "Rename File",                                 mode = "n" },
        },
        lazy = false,
        opts = function()
            local icons = require("utils.icons")
            local utils = require("utils")

            local snacks = require("snacks")

            local function get_picker()
                return snacks.picker.get()[1]
            end

            local function list_down_or_cycle_win(win)
                local picker = get_picker()
                if vim.fn.mode():find("n") then
                    require("snacks.picker.actions").cycle_win(picker)
                else
                    require("snacks.picker.actions").list_down(picker)
                end
            end

            -- https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-1225975038
            local function multiopen(win, method, keep)
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

                if not keep then
                    win:close()
                end

                local picker = get_picker()

                local items = picker:selected({ fallback = true })
                for _, item in ipairs(items) do
                    local filename = snacks.picker.util.path(item)
                    local row = item.pos and item.pos[1] or 1
                    local col = item.pos and item.pos[2] + 1 or 1

                    local entry_bufnr = item.buf

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
            end

            local explorer_layout
            if utils.is_available("edgy.nvim") then
                explorer_layout = {
                    width = 1,
                    col = 0,
                    box = "vertical",
                    {
                        win = "input",
                        bo = {
                            filetype = "snacks_explorer_input",
                        },
                    },
                    {
                        win = "list",
                        bo = {
                            filetype = "snacks_explorer_list",
                        },
                    },
                }
            else
                explorer_layout = {
                    backdrop = false,
                    width = 40,
                    min_width = 40,
                    height = 0,
                    position = "left",
                    border = "none",
                    box = "vertical",
                    {
                        win = "input",
                        height = 1,
                        bo = {
                            filetype = "snacks_explorer_input",
                        },
                    },
                    {
                        win = "list",
                        bo = {
                            filetype = "snacks_explorer_list",
                        },
                    },
                }
            end

            return {
                -- NOTE: 存在直接打开大文件无法检测的情况
                bigfile = {
                    enabled = true,
                    -- Enable or disable features when big file detected
                    ---@param ctx {buf: number, ft:string}
                    setup = function(ctx)
                        if vim.fn.exists(":NoMatchParen") ~= 0 then
                            vim.cmd([[NoMatchParen]])
                        end
                        snacks.util.wo(0, {
                            foldmethod = "manual",
                            statuscolumn = "",
                            conceallevel = 0,
                        })
                        vim.schedule(function()
                            if vim.api.nvim_buf_is_valid(ctx.buf) then
                                vim.bo[ctx.buf].syntax = ctx.ft
                            end
                        end)

                        vim.api.nvim_set_option_value("wrap", false, { scope = "local" })

                        -- https://github.com/LunarVim/bigfile.nvim
                        vim.api.nvim_set_option_value("swapfile", false, { scope = "local" })
                        vim.api.nvim_set_option_value("undolevels", 0, { scope = "local" })
                        vim.api.nvim_set_option_value("undoreload", 0, { scope = "local" })
                        vim.api.nvim_set_option_value("list", false, { scope = "local" })

                        vim.schedule(function()
                            local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
                            local is_treesitter_available = ts_avail and parsers.has_parser()
                            if is_treesitter_available then
                                vim.treesitter.stop(ctx.buf)
                            end
                            vim.api.nvim_set_option_value("syntax", "off", { scope = "local" })
                        end)
                    end,
                },
                dashboard = {
                    enabled = true,
                    -- These settings are used by some built-in sections
                    preset = {
                        -- Used by the `keys` section to show keymaps.
                        -- Set your custom keymaps here.
                        -- When using a function, the `items` argument are the default keymaps.
                        ---@type snacks.dashboard.Item[]
                        keys = {
                            {
                                icon = icons.misc.new_file,
                                key = "n",
                                desc = "New File",
                                action = function()
                                    vim.cmd.enew()
                                    vim.cmd.startinsert()
                                end,
                            },
                            {
                                icon = icons.misc.search,
                                key = "f",
                                desc = "Find File",
                                action = function() snacks.dashboard.pick("files") end,
                            },
                            {
                                icon = icons.misc.search,
                                key = "/",
                                desc = "Find Text",
                                action = function() snacks.dashboard.pick("live_grep") end,
                            },
                            {
                                icon = icons.misc.gear,
                                key = "c",
                                desc = "Config",
                                action = function()
                                    vim.api.nvim_set_current_dir(path.config_path)
                                    vim.api.nvim_command("SessionManager load_current_dir_session")
                                end,
                                enabled = utils.is_available("neovim-session-manager"),
                            },
                            {
                                icon = icons.misc.list_unordered,
                                key = "s",
                                desc = "Load Session",
                                action = function() vim.api.nvim_command("SessionManager load_session") end,
                                enabled = utils.is_available("neovim-session-manager"),
                            },
                            {
                                icon = icons.misc.refresh,
                                key = "S",
                                desc = "Load Last Session",
                                action = function() vim.api.nvim_command("SessionManager load_last_session") end,
                                enabled = utils.is_available("neovim-session-manager"),
                            },
                            {
                                icon = icons.misc.extensions,
                                key = "l",
                                desc = "Lazy",
                                action = function() require("lazy").home() end,
                                enabled = package.loaded.lazy ~= nil,
                            },
                            {
                                icon = icons.misc.close,
                                key = "q",
                                desc = "Quit",
                                action = function() vim.cmd.quitall() end,
                            },
                        },
                    },
                },
                debug = { enabled = true },
                explorer = { enabled = true },
                -- NOTE: 存在以下问题
                -- 1. 大文件内存在性能问题
                -- 2. 相同 buf 的 indent 互相干扰，需要设置 only_current
                -- indent = {
                --     enabled = true,
                --     indent = {
                --         char = icons.misc.left_one_quarter_block,
                --         only_current = true, -- only show indent guides in the current window
                --     },
                --     animate = {
                --         enabled = false,
                --     },
                --     scope = {
                --         char = icons.misc.left_one_quarter_block,
                --         underline = true,    -- underline the start of the scope
                --         only_current = true, -- only show scope in the current window
                --     },
                --     -- filter for buffers to enable indent guides
                --     filter = function(buf)
                --         local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                --         if vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) then
                --             return false
                --         end
                --
                --         local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                --         if vim.tbl_contains(require("utils.filetype").skip_filetype_list, ft) then
                --             return false
                --         end
                --
                --         return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and
                --             vim.bo[buf].buftype == ""
                --     end,
                -- },
                input = { enabled = true },
                lazygit = { enabled = true },
                notifier = {
                    enabled = true,
                    ---@type snacks.notifier.style
                    style = "fancy",
                },
                picker = {
                    enabled = true,
                    hidden = true,
                    ignored = true,
                    sources = {
                        explorer = {
                            prompt = " " .. icons.fold.FoldClosed,
                            watch = false,
                            layout = {
                                cycle = false,
                                layout = explorer_layout,
                            },
                            win = {
                                list = {
                                    keys = {
                                        -- ["<BS>"] = "explorer_up",
                                        ["H"] = {
                                            function(win)
                                                local picker = get_picker()
                                                require("snacks.explorer.actions").actions.explorer_up(picker)
                                                vim.api.nvim_command("cd " .. vim.fs.dirname(picker:cwd()))
                                            end,
                                        },
                                        -- ["l"] = "confirm",
                                        -- ["h"] = "explorer_close", -- close directory
                                        -- ["a"] = "explorer_add",
                                        -- ["d"] = "explorer_del",
                                        -- ["r"] = "explorer_rename",
                                        -- ["c"] = "explorer_copy",
                                        -- ["m"] = "explorer_move",
                                        ["x"] = "explorer_move",
                                        -- ["o"] = "explorer_open", -- open with system application
                                        -- ["P"] = "toggle_preview",
                                        -- ["y"] = { "explorer_yank", mode = { "n", "x" } },
                                        ["c"] = { "explorer_yank", mode = { "n", "x" } },
                                        -- ["p"] = "explorer_paste",
                                        -- ["u"] = "explorer_update",
                                        -- ["<c-c>"] = "tcd",
                                        -- ["<leader>/"] = "picker_grep",
                                        -- ["<c-t>"] = "terminal",
                                        -- ["."] = "explorer_focus",
                                        ["L"] = {
                                            function(win)
                                                local picker = get_picker()
                                                require("snacks.explorer.actions").actions.explorer_focus(picker)
                                                vim.api.nvim_command("cd " .. picker:dir())
                                            end,
                                        },
                                        -- ["I"] = "toggle_ignored",
                                        ["Ti"] = "toggle_ignored",
                                        -- ["H"] = "toggle_hidden",
                                        ["Th"] = "toggle_hidden",
                                        -- ["Z"] = "explorer_close_all",
                                        -- ["]g"] = "explorer_git_next",
                                        -- ["[g"] = "explorer_git_prev",
                                        -- ["]d"] = "explorer_diagnostic_next",
                                        -- ["[d"] = "explorer_diagnostic_prev",
                                        -- ["]w"] = "explorer_warn_next",
                                        -- ["[w"] = "explorer_warn_prev",
                                        -- ["]e"] = "explorer_error_next",
                                        -- ["[e"] = "explorer_error_prev",

                                        ["s"] = function(win)
                                            local items = snacks.picker.get()[1]:selected({ fallback = true })
                                            if #items ~= 2 then
                                                vim.notify("Diff requires specifying 2 files", vim.log.levels.WARN, { title = "Explorer" })
                                                return
                                            end

                                            win:close()

                                            vim.cmd(string.format("%s %s", "tabedit", snacks.picker.util.path(items[1])))
                                            vim.cmd.vnew()
                                            vim.cmd.edit(snacks.picker.util.path(items[2]))

                                            utils.diffthis()
                                        end,
                                        ["t"] = function(win) multiopen(win, "tab", false) end,
                                    },
                                },
                            },
                        },
                    },
                    win = {
                        -- input window
                        input = {
                            keys = {
                                -- to close the picker on ESC instead of going to normal mode,
                                -- add the following keymap to your config
                                -- ["<Esc>"] = { "close", mode = { "n", "i" } },
                                ["<c-q>"] = { "close", mode = { "n", "i" } },
                                -- ["/"] = "toggle_focus",
                                -- ["<C-Down>"] = { "history_forward", mode = { "i", "n" } },
                                -- ["<C-Up>"] = { "history_back", mode = { "i", "n" } },
                                ["<c-p>"] = { "history_forward", mode = { "i", "n" } },
                                ["<c-n>"] = { "history_back", mode = { "i", "n" } },
                                -- ["<C-c>"] = { "cancel", mode = "i" },
                                -- ["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
                                -- ["<CR>"] = { "confirm", mode = { "n", "i" } },
                                -- ["<Down>"] = { "list_down", mode = { "i", "n" } },
                                -- ["<Esc>"] = "cancel",
                                -- ["<S-CR>"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
                                -- ["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" } },
                                -- ["<Tab>"] = { "select_and_next", mode = { "i", "n" } },
                                ["<tab>"] = false,
                                ["<s-up>"] = { "select_and_prev", mode = { "i", "n" } },
                                ["<s-down>"] = { "select_and_next", mode = { "i", "n" } },
                                -- ["<Up>"] = { "list_up", mode = { "i", "n" } },
                                -- ["<a-d>"] = { "inspect", mode = { "n", "i" } },
                                -- ["<a-f>"] = { "toggle_follow", mode = { "i", "n" } },
                                -- ["<a-h>"] = { "toggle_hidden", mode = { "i", "n" } },
                                -- ["<a-i>"] = { "toggle_ignored", mode = { "i", "n" } },
                                -- ["<a-m>"] = { "toggle_maximize", mode = { "i", "n" } },
                                -- ["<a-p>"] = { "toggle_preview", mode = { "i", "n" } },
                                -- ["<a-w>"] = { "cycle_win", mode = { "i", "n" } },
                                -- ["<c-a>"] = { "select_all", mode = { "n", "i" } },
                                -- ["<c-b>"] = { "preview_scroll_up", mode = { "i", "n" } },
                                -- ["<c-d>"] = { "list_scroll_down", mode = { "i", "n" } },
                                -- ["<c-f>"] = { "preview_scroll_down", mode = { "i", "n" } },
                                -- ["<c-g>"] = { "toggle_live", mode = { "i", "n" } },
                                -- ["<c-j>"] = { "list_down", mode = { "i", "n" } },
                                ["<c-j>"] = { list_down_or_cycle_win, mode = { "i", "n" } },
                                -- ["<c-k>"] = { "list_up", mode = { "i", "n" } },
                                -- ["<c-n>"] = { "list_down", mode = { "i", "n" } },
                                -- ["<c-p>"] = { "list_up", mode = { "i", "n" } },
                                -- ["<c-q>"] = { "qflist", mode = { "i", "n" } },
                                -- ["<c-s>"] = { "edit_split", mode = { "i", "n" } },
                                -- ["<c-t>"] = { "tab", mode = { "n", "i" } },
                                ["<c-t>"] = { function(win) multiopen(win, "tab") end, mode = { "n", "i" } },
                                ["<c-i>"] = { function(win) multiopen(win, "tab") end, mode = { "n", "i" } },
                                -- ["<c-u>"] = { "list_scroll_up", mode = { "i", "n" } },
                                -- ["<c-v>"] = { "edit_vsplit", mode = { "i", "n" } },
                                -- ["<c-r>#"] = { "insert_alt", mode = "i" },
                                -- ["<c-r>%"] = { "insert_filename", mode = "i" },
                                -- ["<c-r><c-a>"] = { "insert_cWORD", mode = "i" },
                                -- ["<c-r><c-f>"] = { "insert_file", mode = "i" },
                                -- ["<c-r><c-l>"] = { "insert_line", mode = "i" },
                                -- ["<c-r><c-p>"] = { "insert_file_full", mode = "i" },
                                -- ["<c-r><c-w>"] = { "insert_cword", mode = "i" },
                                -- ["<c-w>H"] = "layout_left",
                                -- ["<c-w>J"] = "layout_bottom",
                                -- ["<c-w>K"] = "layout_top",
                                -- ["<c-w>L"] = "layout_right",
                                -- ["?"] = "toggle_help_input",
                                -- ["G"] = "list_bottom",
                                -- ["gg"] = "list_top",
                                -- ["j"] = "list_down",
                                -- ["k"] = "list_up",
                                -- ["q"] = "close",

                                ["<c-h>"] = { "preview_scroll_left", mode = { "i", "n" } },
                                ["<c-l>"] = { "preview_scroll_right", mode = { "i", "n" } },
                            },
                        },
                        -- result list window
                        list = {
                            keys = {
                                -- ["/"] = "toggle_focus",
                                -- ["<2-LeftMouse>"] = "confirm",
                                -- ["<CR>"] = "confirm",
                                ["l"] = "confirm",
                                -- ["<Down>"] = "list_down",
                                -- ["<Esc>"] = "cancel",
                                -- ["<S-CR>"] = { { "pick_win", "jump" } },
                                -- ["<S-Tab>"] = { "select_and_prev", mode = { "n", "x" } },
                                -- ["<Tab>"] = { "select_and_next", mode = { "n", "x" } },
                                ["K"] = { "select_and_prev", mode = { "n", "x" } },
                                ["J"] = { "select_and_next", mode = { "n", "x" } },
                                -- ["<Up>"] = "list_up",
                                -- ["<a-d>"] = "inspect",
                                -- ["<a-f>"] = "toggle_follow",
                                -- ["<a-h>"] = "toggle_hidden",
                                -- ["<a-i>"] = "toggle_ignored",
                                -- ["<a-m>"] = "toggle_maximize",
                                -- ["<a-p>"] = "toggle_preview",
                                ["Tf"] = "toggle_follow",
                                ["Th"] = "toggle_hidden",
                                ["Ti"] = "toggle_ignored",
                                ["Tm"] = "toggle_maximize",
                                ["Tp"] = "toggle_preview",
                                -- ["<a-w>"] = "cycle_win",
                                ["<Tab>"] = "cycle_win",
                                -- ["<c-a>"] = "select_all",
                                -- ["<c-b>"] = "preview_scroll_up",
                                -- ["<c-d>"] = "list_scroll_down",
                                -- ["<c-f>"] = "preview_scroll_down",
                                -- ["<c-j>"] = "list_down",
                                ["<c-j>"] = { list_down_or_cycle_win, mode = { "i", "n" } },
                                -- ["<c-k>"] = "list_up",
                                -- ["<c-n>"] = "list_down",
                                -- ["<c-p>"] = "list_up",
                                -- ["<c-q>"] = "qflist",
                                -- ["<c-s>"] = "edit_split",
                                ["V"] = "edit_split",
                                -- ["<c-t>"] = "tab",
                                ["t"] = function(win) multiopen(win, "tab") end,
                                -- ["<c-u>"] = "list_scroll_up",
                                -- ["<c-v>"] = "edit_vsplit",
                                ["v"] = "edit_vsplit",
                                -- ["<c-w>H"] = "layout_left",
                                -- ["<c-w>J"] = "layout_bottom",
                                -- ["<c-w>K"] = "layout_top",
                                -- ["<c-w>L"] = "layout_right",
                                -- ["?"] = "toggle_help_list",
                                -- ["G"] = "list_bottom",
                                -- ["gg"] = "list_top",
                                -- ["i"] = "focus_input",
                                -- ["j"] = "list_down",
                                -- ["k"] = "list_up",
                                -- ["q"] = "close",
                                -- ["zb"] = "list_scroll_bottom",
                                -- ["zt"] = "list_scroll_top",
                                -- ["zz"] = "list_scroll_center",
                            },
                        },
                        -- preview window
                        preview = {
                            keys = {
                                -- ["<Esc>"] = "cancel",
                                -- ["q"] = "close",
                                -- ["i"] = "focus_input",
                                -- ["<a-w>"] = "cycle_win",
                            },
                        },
                    },
                    ---@class snacks.picker.db.Config
                    db = {
                        -- path to the sqlite3 library
                        -- If not set, it will try to load the library by name.
                        -- On Windows it will download the library from the internet.
                        sqlite3_path = path.sqlite_path, ---@type string?
                    },
                },
                rename = { enabled = true },
                scope = {
                    enabled = true,
                    -- what buffers to attach to
                    filter = function(buf)
                        local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                        if vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) then
                            return false
                        end

                        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                        if vim.tbl_contains(require("utils.filetype").skip_filetype_list, ft) then
                            return false
                        end

                        return vim.b[buf].snacks_scope ~= false and vim.g.snacks_scope ~= false
                    end,
                },
                -- NOTE: 存在以下问题
                -- 1. 有时第一次滑动无法平滑滚动
                -- 2. 按住滚动时不连贯
                -- 3. 无法禁用部分操作的平滑滚动
                -- scroll = {
                --     enabled = true,
                --     -- what buffers to animate
                --     filter = function(buf)
                --         local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                --         if vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) then
                --             return false
                --         end
                --
                --         local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                --         if vim.tbl_contains(require("utils.filetype").skip_filetype_list, ft) then
                --             return false
                --         end
                --
                --         return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false
                --     end,
                --
                -- },
                terminal = { enabled = true },
                toggle = { enabled = true },
                win = { enabled = true },
                words = { enabled = true },
            }
        end,
        priority = 1000,
    },

    {
        "JuanZoran/Trans.nvim",
        build = function()
            require("Trans").install()
        end,
        cmd = {
            "Translate",
            "TransPlay",
            "TranslateInput",
            "TransToggle",
        },
        config = function(_, opts)
            local Trans = require("Trans")
            Trans.setup(opts)

            if require("utils").is_available("snacks.nvim") then
                local trans_win
                vim.api.nvim_create_user_command("TransToggle", function()
                    if trans_win ~= nil then
                        trans_win:destroy()
                        trans_win = nil
                        return
                    end

                    trans_win = require("snacks").win({
                        width = 0.3,
                        position = "right",
                        enter = false,
                        wo = {
                            wrap = true,
                        },
                        bo = {
                            ft = "trans-view",
                        },
                    })

                    trans_win:on({ "CursorHold", "CursorHoldI" }, function()
                        if require("utils.filetype").is_panel_filetype(vim.bo.filetype) then
                            return
                        end

                        local buf = trans_win.buf

                        local trans_opts = {}
                        trans_opts.mode = trans_opts.mode or vim.fn.mode()
                        trans_opts.str = Trans.util.get_str(trans_opts.mode)
                        local str = trans_opts.str
                        if not str or str == "" then return end

                        local data = Trans.data.new(trans_opts)
                        Trans.backend.offline.query(data)
                        if not data.result.offline then
                            return
                        end

                        local result, name = data:get_available_result()
                        if not result then
                            return
                        end

                        data.frontend.buffer.bufnr = buf

                        vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
                        vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
                        data.frontend:load(result, name, data.frontend.opts.order[name])
                        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
                    end)
                end, { desc = "Toggle trans-view" })
            end
        end,
        dependencies = {
            {
                "kkharji/sqlite.lua",
                config = function(_, opts)
                    vim.g.sqlite_clib_path = "sqlite3.dll"
                    if environment.is_windows then
                        vim.g.sqlite_clib_path = path.sqlite_path
                    end
                end,
            },
        },
        enabled = not environment.is_vscode,
        opts = {
            debug = false,
            frontend = {
                default = {
                    ---@type {open: string | boolean, close: string | boolean, interval: integer} Hover Window Animation
                    animation = {
                        open = false, -- 'fold', 'slid'
                        close = false,
                    },
                },
                hover = {
                    ---@type string[] auto close events
                    auto_close_events = false,
                    ---@type table<string, string[]> order to display translate result
                    order = {
                        offline = {
                            "title",
                            "translation",
                            "exchange",
                            "pos",
                            "tag",
                            "definition",
                        },
                    },
                },
            },
        },
    },

    {
        "y3owk1n/undo-glow.nvim",
        enabled = not environment.is_vscode,
        init = function()
            local utils = require("utils")
            utils.create_once_autocmd("User", {
                callback = function()
                    if not utils.is_available("yanky.nvim") then
                        vim.api.nvim_create_autocmd("TextYankPost", {
                            callback = function()
                                require("undo-glow").yank()
                            end,
                            desc = "Highlight when yanking (copying) text",
                        })
                    end

                    -- This only handles neovim instance and do not highlight when switching panes in tmux
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        callback = function()
                            require("undo-glow").cursor_moved({
                                animation = {
                                    animation_type = "slide",
                                },
                            })
                        end,
                        desc = "Highlight when cursor moved significantly",
                    })

                    -- This will handle highlights when focus gained, including switching panes in tmux
                    vim.api.nvim_create_autocmd("FocusGained", {
                        callback = function()
                            ---@type UndoGlow.CommandOpts
                            local opts = {
                                animation = {
                                    animation_type = "slide",
                                },
                            }

                            opts = require("undo-glow.utils").merge_command_opts("UgCursor", opts)
                            local current_row = vim.api.nvim_win_get_cursor(0)[1]
                            local cur_line = vim.api.nvim_get_current_line()
                            require("undo-glow").highlight_region(vim.tbl_extend("force", opts, {
                                s_row = current_row - 1,
                                s_col = 0,
                                e_row = current_row - 1,
                                e_col = #cur_line,
                                force_edge = opts.force_edge == nil and true or opts.force_edge,
                            }))
                        end,
                        desc = "Highlight when focus gained",
                    })

                    vim.api.nvim_create_autocmd("CmdLineLeave", {
                        callback = function()
                            require("undo-glow").search_cmd({
                                animation = {
                                    animation_type = "fade",
                                },
                            })
                        end,
                        desc = "Highlight when search cmdline leave",
                        pattern = { "/", "?" },
                    })
                end,
                desc = "undo-glow init",
                pattern = "IceLoad",
            })
        end,
        keys = {
            { "u",     function() require("undo-glow").undo() end, desc = "Undo with highlight", mode = "n" },
            { "<c-r>", function() require("undo-glow").redo() end, desc = "Redo with highlight", mode = "n" },
        },
        opts = {
            animation = {
                enabled = true,       -- whether to turn on or off for animation
                duration = 1000,      -- in ms
                window_scoped = true, -- this uses an experimental extmark options (it might not work depends on your version of neovim)
            },
        },
    },
}
