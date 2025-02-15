local buftype = require("utils.buftype")
local colors = require("utils.colors")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local icons = require("utils.icons")
local treesitter = require("utils.treesitter")
local utils = require("utils")

return {
    {
        "altermo/ultimate-autopair.nvim",
        config = function(_, opts)
            if utils.is_available("nvim-cmp") then
                require("ultimate-autopair").init({
                    require("ultimate-autopair").extend_default(opts),
                    { profile = require("ultimate-autopair.experimental.cmpair").init },
                })
            else
                require("ultimate-autopair").setup(opts)
            end
        end,
        enabled = not environment.is_vscode,
        event = {
            "CmdlineEnter",
            "InsertEnter",
        },
        opts = {
            space = {
                enable = false,
            },
        },
    },

    {
        "danymat/neogen",
        cmd = {
            "Neogen",
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = environment.treesitter_enable,
        keys = {
            { "<leader>gca", function() require("neogen").generate() end, desc = "Generate annotation", mode = { "n", "x" } },
        },
        opts = function()
            local opts = {}

            if not environment.is_vscode then
                opts["snippet_engine"] = "luasnip"
            end

            return opts
        end,
    },

    {
        "echasnovski/mini.ai",
        keys = {
            { "a(",  mode = { "x", "o" } },
            { "i(",  mode = { "x", "o" } },
            { "a[",  mode = { "x", "o" } },
            { "i[",  mode = { "x", "o" } },
            { "a{",  mode = { "x", "o" } },
            { "i{",  mode = { "x", "o" } },
            { "a<",  mode = { "x", "o" } },
            { "i<",  mode = { "x", "o" } },
            { "a)",  mode = { "x", "o" } },
            { "i)",  mode = { "x", "o" } },
            { "a]",  mode = { "x", "o" } },
            { "i]",  mode = { "x", "o" } },
            { "a}",  mode = { "x", "o" } },
            { "i}",  mode = { "x", "o" } },
            { "a>",  mode = { "x", "o" } },
            { "i>",  mode = { "x", "o" } },
            { "ab",  mode = { "x", "o" } },
            { "ib",  mode = { "x", "o" } },
            { "a\"", mode = { "x", "o" } },
            { "i\"", mode = { "x", "o" } },
            { "a'",  mode = { "x", "o" } },
            { "i'",  mode = { "x", "o" } },
            { "a`",  mode = { "x", "o" } },
            { "i`",  mode = { "x", "o" } },
            { "aq",  mode = { "x", "o" } },
            { "iq",  mode = { "x", "o" } },
            { "a?",  mode = { "x", "o" } },
            { "i?",  mode = { "x", "o" } },
            { "at",  mode = { "x", "o" } },
            { "it",  mode = { "x", "o" } },
            -- 由 nvim-treesitter-textobjects 设置
            -- { "af",  mode = { "x", "o" } },
            -- { "if",  mode = { "x", "o" } },
            -- { "aa",  mode = { "x", "o" } },
            -- { "ia",  mode = { "x", "o" } },
            { "a_",  mode = { "x", "o" } },
            { "i_",  mode = { "x", "o" } },
            { "a ",  mode = { "x", "o" } },
            { "i ",  mode = { "x", "o" } },
            { "a,",  mode = { "x", "o" } },
            { "i,",  mode = { "x", "o" } },
            { "a.",  mode = { "x", "o" } },
            { "i.",  mode = { "x", "o" } },
            { "ae",  mode = { "x", "o" } },
            { "ie",  mode = { "x", "o" } },
            { "ar",  mode = { "x", "o" } },
            { "ir",  mode = { "x", "o" } },
            { "av",  mode = { "x", "o" } },
            { "iv",  mode = { "x", "o" } },
        },
        opts = {
            -- Table with textobject id as fields, textobject specification as values.
            -- Also use this to disable builtin textobjects. See |MiniAi.config|.
            custom_textobjects = {
                [","] = { "%b<>", "^.%s*().-()%s*.$" },
                ["."] = { "%b<>", "^.().*().$" },
                e = function(ai_type)
                    local n_lines = vim.fn.line("$")
                    local start_line, end_line = 1, n_lines
                    if ai_type == "i" then
                        -- Skip first and last blank lines for `i` textobject
                        local first_nonblank, last_nonblank = vim.fn.nextnonblank(1), vim.fn.prevnonblank(n_lines)
                        start_line = first_nonblank == 0 and 1 or first_nonblank
                        end_line = last_nonblank == 0 and n_lines or last_nonblank
                    end

                    local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                    return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
                end,
                r = { { "%b[]" }, "^.().*().$" },
                v = {
                    {
                        "%f[%w]()%w+()[-_]",
                        "[-_]()%w+()%f[%W]",
                        "%f[-_%u]()%u[%d%l]+()%f[^-_%d%l]",
                        "%f[-_%w]()[%d%l]+()%f[^-_%d%l]",
                    },
                },
            },

            -- Number of lines within which textobject is searched
            n_lines = math.huge,
        },
    },
    {
        "echasnovski/mini.operators",
        keys = {
            { "se",    desc = "Evaluate text and replace with output", mode = { "n", "x" } },
            { "sx",    desc = "Exchange text regions",                 mode = { "n", "x" } },
            { "<c-c>", desc = "Stop exchanging after the first step",  mode = { "n", "x" } },
            { "sm",    desc = "Multiply (duplicate) text",             mode = { "n", "x" } },
            { "ss",    desc = "Replace text with register",            mode = { "n", "x" } },
            { "sS",    desc = "Sort text",                             mode = { "n", "x" } },
        },
        opts = {
            -- Evaluate text and replace with output
            evaluate = {
                prefix = "se",
            },

            -- Exchange text regions
            exchange = {
                prefix = "sx",
            },

            -- Multiply (duplicate) text
            multiply = {
                prefix = "sm",
            },

            -- Replace text with register
            replace = {
                prefix = "ss",
            },

            -- Sort text
            sort = {
                prefix = "sS",
            },
        },
    },
    {
        "echasnovski/mini.splitjoin",
        keys = {
            { "gs", desc = "Split join", mode = "n" },
        },
        opts = {
            -- Module mappings. Use `''` (empty string) to disable one.
            -- Created for both Normal and Visual modes.
            mappings = {
                toggle = "gs",
            },
        },
    },

    -- NOTE: 需要安装 ripgrep
    {
        "folke/todo-comments.nvim",
        cmd = {
            "TodoQuickFix",
            "TodoLocList",
            "TodoTrouble",
            "TodoTelescope",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "<leader>xt", function() vim.api.nvim_command("TodoTrouble") end, desc = "List all project todos in trouble", mode = "n" },
        },
        opts = function()
            local keywords = {
                FIX = { icon = icons.misc.bug, color = colors.get_color(colors.colors.red), alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = icons.misc.check, color = colors.get_color(colors.colors.green) },
                HACK = { icon = icons.misc.flame, color = colors.get_color(colors.colors.orange) },
                WARN = { icon = icons.diagnostics.Warn, color = colors.get_color(colors.colors.yellow), alt = { "WARNING", "XXX" } },
                PERF = { icon = icons.misc.clock, color = colors.get_color(colors.colors.purple), alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = icons.diagnostics.Info, color = colors.get_color(colors.colors.blue), alt = { "INFO" } },
                TEST = { icon = icons.misc.beaker, color = colors.get_color(colors.colors.cyan), alt = { "TESTING", "PASSED", "FAILED" } },
            }
            -- 忽略大小写
            for key, value in pairs(keywords) do
                value = vim.deepcopy(value)
                local alt = value.alt
                if alt then
                    value.alt = vim.tbl_map(string.lower, alt)
                end
                keywords[key:lower()] = value
            end

            return {
                -- keywords recognized as todo comments
                keywords = keywords,
                -- highlighting of the line containing the todo comment
                -- * before: highlights before the keyword (typically comment characters)
                -- * keyword: highlights of the keyword
                -- * after: highlights after the keyword (todo text)
                highlight = {
                    keyword = "bg", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
                    comments_only = false, -- uses treesitter to match keywords in comments only
                },
            }
        end,
    },

    {
        "gbprod/yanky.nvim",
        keys = {
            { "y", "<plug>(YankyYank)",      desc = "Yank",            mode = { "n", "x" } },
            { "p", "<plug>(YankyPutAfter)",  desc = "Yank put after",  mode = { "n", "x" } },
            { "P", "<plug>(YankyPutBefore)", desc = "Yank put before", mode = { "n", "x" } },
            -- { "gp", "<plug>(YankyGPutAfter)",  desc = "YankG put after",  mode = { "n", "x" } },
            -- { "gP", "<plug>(YankyGPutBefore)", desc = "YankG put before", mode = { "n", "x" } },
        },
        opts = {
            ring = {
                history_length = 0,
                storage = "memory",
            },
        },
    },

    {
        "HiPhish/rainbow-delimiters.nvim",
        config = function(_, opts)
            require("rainbow-delimiters.setup").setup(opts)
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not environment.is_vscode and environment.treesitter_enable,
        ft = treesitter.treesitter_filetype_list,
        opts = {},
    },

    -- NOTE: 需要安装 im-select
    {
        "keaising/im-select.nvim",
        enabled = environment.is_windows,
        event = {
            "InsertEnter",
        },
        opts = function()
            local default_im_select = "com.apple.keylayout.ABC"
            local default_command = "im-select"
            if environment.is_windows or environment.is_wsl then
                default_im_select = "1033"
                default_command = "im-select.exe"
            elseif environment.is_mac then
                default_im_select = "com.apple.keylayout.ABC"
            elseif environment.is_linux then
                default_im_select = "keyboard-us"
                default_command = "fcitx5-remote"
            end

            return {
                -- IM will be set to `default_im_select` in `normal` mode
                -- For Windows/WSL, default: "1033", aka: English US Keyboard
                -- For macOS, default: "com.apple.keylayout.ABC", aka: US
                -- For Linux, default:
                --               "keyboard-us" for Fcitx5
                --               "1" for Fcitx
                --               "xkb:us::eng" for ibus
                -- You can use `im-select` or `fcitx5-remote -n` to get the IM's name
                default_im_select  = default_im_select,

                -- Can be binary's name, binary's full path, or a table, e.g. 'im-select',
                -- '/usr/local/bin/im-select' for binary without extra arguments,
                -- or { "AIMSwitcher.exe", "--imm" } for binary need extra arguments to work.
                -- For Windows/WSL, default: "im-select.exe"
                -- For macOS, default: "macism"
                -- For Linux, default: "fcitx5-remote" or "fcitx-remote" or "ibus"
                default_command    = default_command,

                -- Restore the default input method state when the following events are triggered
                set_default_events = { "InsertLeave" },
            }
        end,
    },

    {
        "monaqa/dial.nvim",
        config = function()
            local augend = require("dial.augend")
            require("dial.config").augends:register_group({
                default = {
                    augend.case.new({
                        types = { "camelCase", "snake_case" },
                        cyclic = true,
                    }),

                    augend.constant.alias.Alpha,
                    augend.constant.alias.alpha,
                    augend.constant.alias.bool,
                    augend.constant.new({
                        elements = { "True", "False" },
                        word = true,
                        cyclic = true,
                    }),
                    augend.constant.new({
                        elements = { "and", "or" },
                        word = true,
                        cyclic = true,
                    }),
                    augend.constant.new({
                        elements = { "&&", "||" },
                        word = false,
                        cyclic = true,
                    }),

                    augend.date.alias["%Y/%m/%d"],
                    augend.date.alias["%-m/%-d"],
                    augend.date.alias["%Y-%m-%d"],
                    augend.date.alias["%Y年%-m月%-d日"],
                    augend.date.new({
                        pattern = "%Y/%-m/%-d",
                        default_kind = "day",
                        only_valid = true,
                        word = false,
                    }),
                    augend.date.alias["%H:%M:%S"],
                    augend.date.alias["%H:%M"],

                    augend.decimal_fraction.new({
                        signed = true,
                        point_char = ".",
                    }),

                    augend.hexcolor.new({
                        case = "lower",
                    }),

                    augend.integer.alias.binary,
                    augend.integer.alias.decimal_int,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,

                    augend.misc.alias["markdown_header"],

                    augend.semver.alias.semver,
                },
            })
        end,
        keys = {
            { "<c-a>",  function() require("dial.map").manipulate("increment", "normal") end,  desc = "Increase", mode = "n" },
            { "<c-x>",  function() require("dial.map").manipulate("decrement", "normal") end,  desc = "Decrease", mode = "n" },
            { "g<c-a>", function() require("dial.map").manipulate("increment", "gnormal") end, desc = "Increase", mode = "n" },
            { "g<c-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, desc = "Decrease", mode = "n" },
            { "<c-a>",  function() require("dial.map").manipulate("increment", "visual") end,  desc = "Increase", mode = "x" },
            { "<c-x>",  function() require("dial.map").manipulate("decrement", "visual") end,  desc = "Decrease", mode = "x" },
            { "g<c-a>", function() require("dial.map").manipulate("increment", "gvisual") end, desc = "Increase", mode = "x" },
            { "g<c-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, desc = "Decrease", mode = "x" },
        },
    },

    {
        "numToStr/Comment.nvim",
        config = function(_, opts)
            require("Comment").setup(opts)

            local ft = require("Comment.ft")
            ft.python = { "#%s", [["""%s"""]] }
        end,
        enabled = not environment.is_vscode,
        keys = {
            { "gc", desc = "Comment toggle linewise",  mode = { "n", "x" } },
            { "gb", desc = "Comment toggle blockwise", mode = { "n", "x" } },
        },
        opts = {
            ---LHS of toggle mappings in NORMAL mode
            toggler = {
                ---Block-comment toggle keymap
                block = "gbb",
            },
            ---Function to call before (un)comment
            post_hook = function(ctx)
                -- block-comment 换行

                -- 跳过 line-comment
                if ctx.ctype == 1 then
                    return
                end

                if ctx.range.srow == -1 then
                    return
                end

                local C = require("Comment.config")
                local F = require("Comment.ft")
                local U = require("Comment.utils")

                local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
                local cstr = F.get(ft, ctx.ctype)
                local lcs, rcs = U.unwrap_cstr(cstr)
                lcs = vim.pesc(lcs)
                rcs = vim.pesc(rcs)
                local padding = U.get_pad(C:get().padding)

                local lines = vim.api.nvim_buf_get_lines(0, ctx.range.srow - 1, ctx.range.erow, false)
                if ctx.cmode == 1 then
                    -- comment
                    local str = lines[1]
                    local i, j = string.find(str, lcs .. padding)
                    lines[1] = string.sub(str, i, j - #padding)
                    table.insert(lines, 2, string.sub(str, 0, i - 1) .. string.sub(str, j + #padding, #str))

                    str = lines[#lines]
                    i, j = string.find(str, rcs)
                    lines[#lines] = string.sub(str, 0, i - #padding - 1)
                    table.insert(lines, #lines + 1, string.sub(str, i, j))
                elseif ctx.cmode == 2 then
                    -- uncomment
                    if #lines[1] == 0 and #lines[#lines] == 0 then
                        table.remove(lines, 1)
                        table.remove(lines, #lines)
                    end
                end
                vim.api.nvim_buf_set_lines(0, ctx.range.srow - 1, ctx.range.erow, false, lines)
            end,
        },
    },

    {
        "okuuva/auto-save.nvim",
        cmd = {
            "ASToggle",
        },
        config = function(_, opts)
            require("auto-save").setup(opts)

            local trailspace_interval = 3
            local prev_trailspace_time = os.time()

            local ts
            if utils.is_available("mini.trailspace") then
                ts = function()
                    require("mini.trailspace").trim()
                end
            end

            local function trailspace()
                if ts == nil then
                    return
                end

                -- 新行不清空尾随空格
                if vim.api.nvim_get_current_line():match("^%s*$") ~= nil then
                    return
                end

                -- 当处于 LuaSnip 的 snippet 时，不清空尾随空格
                if utils.is_available("LuaSnip") and package.loaded["luasnip"] then
                    if require("luasnip").in_snippet() then
                        return
                    end
                end

                -- 间隔小于指定间隔时，不清空尾随空格
                local trailspace_time = os.time()
                if trailspace_time - prev_trailspace_time <= trailspace_interval then
                    return
                end

                ts()

                prev_trailspace_time = trailspace_time
            end

            local last_paste_start = vim.fn.getpos("'[")
            local last_paste_end = vim.fn.getpos("']")

            local augroup = vim.api.nvim_create_augroup("AutoSaveWritePreAndPost", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                callback = function(args)
                    if args.data.saved_buffer ~= nil then
                        trailspace()

                        -- 保存文件前保存上次复制的范围
                        last_paste_start = vim.fn.getpos("'[")
                        last_paste_end = vim.fn.getpos("']")
                    end
                end,
                desc = "AutoSaveWritePre event",
                group = augroup,
                pattern = "AutoSaveWritePre",
            })
            vim.api.nvim_create_autocmd("User", {
                callback = function(args)
                    if args.data.saved_buffer ~= nil then
                        -- 读取上次复制的范围
                        vim.fn.setpos("'[", last_paste_start)
                        vim.fn.setpos("']", last_paste_end)
                    end
                end,
                group = augroup,
                desc = "AutoSaveWritePost event",
                pattern = "AutoSaveWritePost",
            })
        end,
        enabled = not environment.is_vscode,
        init = function()
            if vim.g.autosave_enabled == nil then
                vim.g.autosave_enabled = true
            end

            -- auto-save 自动激活
            vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertLeave", "TextChanged" }, {
                callback = function(args)
                    if package.loaded["auto-save"] then
                        pcall(vim.api.nvim_del_augroup_by_name, "AutoSaveActivate")
                        return
                    end

                    local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
                    local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = args.buf })
                    local is_modified = vim.api.nvim_get_option_value("modified", { buf = args.buf })
                    if not vim.tbl_contains(buftype.skip_buftype_list, bt) and is_modifiable and is_modified then
                        pcall(vim.cmd.write)
                        require("auto-save")
                        vim.api.nvim_del_augroup_by_name("AutoSaveActivate")
                    end
                end,
                desc = "AutoSave event",
                group = vim.api.nvim_create_augroup("AutoSaveActivate", { clear = true }),
            })
        end,
        keys = {
            { "<leader>cta", function() utils.toggle_global_setting("autosave_enabled", function(enabled, prev_enabled, global_enabled) end) end, desc = "Toggle autoSave",          mode = "n" },
            { "<leader>ctA", function() utils.toggle_buffer_setting("autosave_enabled", function(enabled, prev_enabled) end) end,                 desc = "Toggle autoSave (buffer)", mode = "n" },
        },
        opts = {
            -- function that takes the buffer handle and determines whether to save the current buffer or not
            -- return true: if buffer is ok to be saved
            -- return false: if it's not ok to be saved
            -- if set to `nil` then no specific condition is applied
            condition = function(buf)
                local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                    return false
                end

                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if vim.tbl_contains(filetype.skip_filetype_list, ft) then
                    return false
                end

                return vim.b[buf].autosave_enabled == nil and vim.g.autosave_enabled or vim.b[buf].autosave_enabled
            end,
            debounce_delay = 1, -- delay after which a pending save is executed
        },
    },

    {
        "utilyre/sentiment.nvim",
        cmd = {
            "NoMatchParen",
            "DoMatchParen",
        },
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        init = function()
            -- `matchparen.vim` needs to be disabled manually in case of lazy loading
            vim.g.loaded_matchparen = 1
        end,
        opts = {},
    },
}
