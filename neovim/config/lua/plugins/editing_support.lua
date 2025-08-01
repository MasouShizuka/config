local environment = require("utils.environment")

return {
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
                if require("utils").is_available("LuaSnip") then
                    opts["snippet_engine"] = "luasnip"
                else
                    opts["snippet_engine"] = "nvim"
                end
            end

            return opts
        end,
    },

    {
        "echasnovski/mini.ai",
        keys = {
            { "i(",  mode = { "x", "o" } },
            { "a(",  mode = { "x", "o" } },
            { "i[",  mode = { "x", "o" } },
            { "a[",  mode = { "x", "o" } },
            { "i{",  mode = { "x", "o" } },
            { "a{",  mode = { "x", "o" } },
            { "i<",  mode = { "x", "o" } },
            { "a<",  mode = { "x", "o" } },
            { "i)",  mode = { "x", "o" } },
            { "a)",  mode = { "x", "o" } },
            { "i]",  mode = { "x", "o" } },
            { "a]",  mode = { "x", "o" } },
            { "i}",  mode = { "x", "o" } },
            { "a}",  mode = { "x", "o" } },
            { "i>",  mode = { "x", "o" } },
            { "a>",  mode = { "x", "o" } },
            { "ib",  mode = { "x", "o" } },
            { "ab",  mode = { "x", "o" } },
            { "i\"", mode = { "x", "o" } },
            { "a\"", mode = { "x", "o" } },
            { "i'",  mode = { "x", "o" } },
            { "a'",  mode = { "x", "o" } },
            { "i`",  mode = { "x", "o" } },
            { "a`",  mode = { "x", "o" } },
            { "iq",  mode = { "x", "o" } },
            { "aq",  mode = { "x", "o" } },
            { "i?",  mode = { "x", "o" } },
            { "a?",  mode = { "x", "o" } },
            { "it",  mode = { "x", "o" } },
            { "at",  mode = { "x", "o" } },
            { "if",  mode = { "x", "o" } },
            { "af",  mode = { "x", "o" } },
            { "ia",  mode = { "x", "o" } },
            { "aa",  mode = { "x", "o" } },
            { "i_",  mode = { "x", "o" } },
            { "a_",  mode = { "x", "o" } },
            { "i ",  mode = { "x", "o" } },
            { "a ",  mode = { "x", "o" } },

            { "i,",  mode = { "x", "o" } },
            { "a,",  mode = { "x", "o" } },
            { "i.",  mode = { "x", "o" } },
            { "a.",  mode = { "x", "o" } },
            { "id",  mode = { "x", "o" } },
            { "ad",  mode = { "x", "o" } },
            { "ie",  mode = { "x", "o" } },
            { "ae",  mode = { "x", "o" } },
            { "io",  mode = { "x", "o" } },
            { "ao",  mode = { "x", "o" } },
            { "ir",  mode = { "x", "o" } },
            { "ar",  mode = { "x", "o" } },
            { "iu",  mode = { "x", "o" } },
            { "au",  mode = { "x", "o" } },
            { "iU",  mode = { "x", "o" } },
            { "aU",  mode = { "x", "o" } },
            { "iv",  mode = { "x", "o" } },
            { "av",  mode = { "x", "o" } },
        },
        opts = function()
            local ai = require("mini.ai")
            return {
                -- Table with textobject id as fields, textobject specification as values.
                -- Also use this to disable builtin textobjects. See |MiniAi.config|.
                custom_textobjects = {
                    [","] = { "%b<>", "^.%s*().-()%s*.$" },
                    ["."] = { "%b<>", "^.().*().$" },
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
                    -- https://github.com/echasnovski/mini.extra
                    d = function(ai_type)
                        local cur_diag = vim.diagnostic.get(0)

                        local regions = {}
                        for _, diag in ipairs(cur_diag) do
                            local from = { line = diag.lnum + 1, col = diag.col + 1 }
                            local to = { line = diag.end_lnum + 1, col = diag.end_col }
                            if to.line == nil or to.col == nil then to = { line = diag.lnum + 1, col = diag.col + 1 } end
                            table.insert(regions, { from = from, to = to })
                        end
                        return regions
                    end,
                    -- https://github.com/echasnovski/mini.extra
                    e = function(ai_type)
                        local start_line, end_line = 1, vim.fn.line("$")
                        if ai_type == "i" then
                            -- Skip first and last blank lines for `i` textobject
                            local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
                            -- Do nothing for buffer with all blanks
                            if first_nonblank == 0 or last_nonblank == 0 then return { from = { line = start_line, col = 1 } } end
                            start_line, end_line = first_nonblank, last_nonblank
                        end

                        local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                        return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
                    end,
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
                    o = ai.gen_spec.treesitter({                                                  -- code block
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }),
                    r = { { "%b[]" }, "^.().*().$" },
                    u = ai.gen_spec.function_call(),                           -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
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
            }
        end,
    },
    {
        "echasnovski/mini.operators",
        keys = {
            { "se",    desc = "Evaluate text and replace with output", mode = { "n", "x" } },
            { "sx",    desc = "Exchange text regions",                 mode = { "n", "x" } },
            { "<c-c>", desc = "Stop exchanging after the first step",  mode = { "n", "x" } },
            { "sm",    desc = "Multiply (duplicate) text",             mode = { "n", "x" } },
            { "ss",    desc = "Replace text with register",            mode = { "n", "x" } },
            { "SS",    '"+ss',                                         desc = "Replace text with register", mode = { "n", "x" }, remap = true },
            { "sS",    desc = "Sort text",                             mode = { "n", "x" } },
        },
        opts = {
            -- Evaluate text and replace with output
            evaluate = {
                -- prefix = "g=",
                prefix = "se",
            },

            -- Exchange text regions
            exchange = {
                -- prefix = "gx",
                prefix = "sx",
            },

            -- Multiply (duplicate) text
            multiply = {
                -- prefix = "gm",
                prefix = "sm",
            },

            -- Replace text with register
            replace = {
                -- prefix = "gr",
                prefix = "ss",
            },

            -- Sort text
            sort = {
                -- prefix = "gs",
                prefix = "sS",
            },
        },
    },
    {
        "echasnovski/mini.pairs",
        config = function(_, opts)
            local pairs = require("mini.pairs")
            pairs.setup(opts)

            opts = {
                -- skip autopair when next character is one of these
                -- skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
                -- skip autopair when the cursor is inside these treesitter nodes
                -- skip_ts = { "string" },
                -- skip autopair when next character is closing pair
                -- and there are more closing pairs than opening pairs
                skip_unbalanced = true,
                -- better deal with markdown code blocks
                markdown = true,
            }

            -- lazyvim.util.mini.pairs
            local open = pairs.open
            pairs.open = function(pair, neigh_pattern)
                if vim.fn.getcmdline() ~= "" then
                    return open(pair, neigh_pattern)
                end
                local o, c = pair:sub(1, 1), pair:sub(2, 2)
                local line = vim.api.nvim_get_current_line()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local next = line:sub(cursor[2] + 1, cursor[2] + 1)
                local before = line:sub(1, cursor[2])
                if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
                    return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
                end
                if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
                    return o
                end
                if opts.skip_ts and #opts.skip_ts > 0 then
                    local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
                    for _, capture in ipairs(ok and captures or {}) do
                        if vim.tbl_contains(opts.skip_ts, capture.capture) then
                            return o
                        end
                    end
                end
                if opts.skip_unbalanced and next == c and c ~= o then
                    local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
                    local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
                    if count_close > count_open then
                        return o
                    end
                end
                return open(pair, neigh_pattern)
            end
        end,
        event = {
            "CmdlineEnter",
            "InsertEnter",
        },
        opts = {
            -- In which modes mappings from this `config` should be created
            modes = { command = true },
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
                -- toggle = "gS",
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
            "User IceLoad",
        },
        keys = {
            { "<leader>xt", function() vim.api.nvim_command("Trouble todo") end, desc = "List all project todos in trouble", mode = "n" },
        },
        opts = function()
            local function get_keyword()
                local colors = require("utils.colors")
                local icons = require("utils.icons")

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

                return keywords
            end

            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    require("todo-comments").setup({ keywords = get_keyword() })
                end,
                desc = "Reload keywords color of todo-comments when changing colorscheme",
                group = vim.api.nvim_create_augroup("TodoCommentsReloadColor", { clear = true }),
            })

            return {
                -- keywords recognized as todo comments
                keywords = get_keyword(),
                -- highlighting of the line containing the todo comment
                -- * before: highlights before the keyword (typically comment characters)
                -- * keyword: highlights of the keyword
                -- * after: highlights after the keyword (todo text)
                highlight = {
                    keyword = "bg",        -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
                    comments_only = false, -- uses treesitter to match keywords in comments only
                },
            }
        end,
    },

    {
        "gbprod/yanky.nvim",
        keys = {
            { "y",         "<plug>(YankyYank)",                      desc = "Yank",                                  mode = { "n", "x" } },
            { "Y",         '"+<plug>(YankyYank)',                    desc = "Yank",                                  mode = { "n", "x" } },
            { "p",         "<plug>(YankyPutAfter)",                  desc = "Put yanked text after cursor",          mode = { "n", "x" } },
            { "P",         "<plug>(YankyPutBefore)",                 desc = "Put yanked text before cursor",         mode = { "n", "x" } },
            { "<leader>p", '"+<plug>(YankyPutAfter)',                desc = "Put yanked text after cursor",          mode = { "n", "x" } },
            { "<leader>P", '"+<plug>(YankyPutBefore)',               desc = "Put yanked text before cursor",         mode = { "n", "x" } },
            { "]p",        "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put indented after cursor (linewise)",  mode = { "n", "x" } },
            { "[p",        "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put indented after cursor (linewise)",  mode = { "n", "x" } },
            { "]P",        "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put indented before cursor (linewise)", mode = { "n", "x" } },
            { "[P",        "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put indented before cursor (linewise)", mode = { "n", "x" } },
            { ">p",        "<Plug>(YankyPutIndentAfterShiftRight)",  desc = "Put and indent right",                  mode = { "n", "x" } },
            { "<p",        "<Plug>(YankyPutIndentAfterShiftLeft)",   desc = "Put and indent left",                   mode = { "n", "x" } },
            { ">P",        "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right",           mode = { "n", "x" } },
            { "<P",        "<Plug>(YankyPutIndentBeforeShiftLeft)",  desc = "Put before and indent left",            mode = { "n", "x" } },
            { "=p",        "<Plug>(YankyPutAfterFilter)",            desc = "Put after applying a filter",           mode = { "n", "x" } },
            { "=P",        "<Plug>(YankyPutBeforeFilter)",           desc = "Put before applying a filter",          mode = { "n", "x" } },
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
        event = {
            "User TreesitterFile",
        },
        opts = {},
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

                    augend.constant.alias.en_weekday_full,
                    augend.constant.new({
                        elements = { "周一", "周二", "周三", "周四", "周五", "周六", "周日" },
                        word = false,
                        cyclic = true,
                    }),
                    augend.constant.new({
                        elements = { "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期天" },
                        word = false,
                        cyclic = true,
                    }),
                    augend.constant.new({
                        elements = { "true", "false" },
                        word = true,
                        cyclic = true,
                    }),
                    augend.constant.new({
                        elements = { "True", "False" },
                        word = true,
                        cyclic = true,
                    }),
                    augend.constant.new({
                        elements = { "and", "or" },
                        word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                        cyclic = true, -- "or" is incremented into "and".
                    }),
                    augend.constant.new({
                        elements = { "&&", "||" },
                        word = false,
                        cyclic = true,
                    }),

                    augend.date.new({
                        pattern = "%Y/%-m/%-d",
                        default_kind = "day",
                        -- if true, it does not match dates which does not exist, such as 2022/05/32
                        only_valid = true,
                        -- if true, it only matches dates with word boundary
                        word = false,
                    }),
                    augend.date.alias["%-m/%-d"],
                    augend.date.alias["%Y-%m-%d"],
                    augend.date.alias["%Y年%-m月%-d日"],
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
                    augend.integer.alias.decimal,
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
                -- block = "gbc",
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

            if vim.g.autosave == nil then
                vim.g.autosave = true
            end

            local utils = require("utils")

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
            local utils = require("utils")

            -- auto-save 自动激活
            local id
            id = vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertLeave", "TextChanged" }, {
                callback = function(args)
                    if package.loaded["auto-save"] then
                        pcall(vim.api.nvim_del_autocmd, id)
                        return
                    end

                    local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
                    local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = args.buf })
                    local is_modified = vim.api.nvim_get_option_value("modified", { buf = args.buf })
                    if not vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) and is_modifiable and is_modified then
                        pcall(vim.cmd.write)
                        require("lazy").load({ plugins = "auto-save.nvim" })
                        vim.api.nvim_del_autocmd(id)
                    end
                end,
                desc = "AutoSave event",
            })

            utils.create_once_autocmd("User", {
                callback = function()
                    utils.set_setting_toggle("autosave", {
                        default = true,
                        g = {
                            keymap = { keys = "<leader>cta", mode = "n" },
                            opts = {
                                callback = function(enabled, prev_enabled, global_enabled)
                                    if not package.loaded["auto-save"] then
                                        require("lazy").load({ plugins = "auto-save.nvim" })
                                    end
                                end,
                            },
                        },
                        b = {
                            keymap = { keys = "<leader>ctA", mode = "n" },
                            opts = {
                                callback = function(enabled, prev_enabled, global_enabled)
                                    if not package.loaded["auto-save"] then
                                        require("lazy").load({ plugins = "auto-save.nvim" })
                                    end
                                end,
                            },
                        },
                    })
                end,
                desc = "Toggle autosave",
                pattern = "IceLoad",
            })
        end,
        opts = {
            -- function that takes the buffer handle and determines whether to save the current buffer or not
            -- return true: if buffer is ok to be saved
            -- return false: if it's not ok to be saved
            -- if set to `nil` then no specific condition is applied
            condition = function(buf)
                local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                if vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt) then
                    return false
                end

                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if vim.tbl_contains(require("utils.filetype").skip_filetype_list, ft) then
                    return false
                end

                if vim.b[buf].autosave == nil then
                    return vim.g.autosave
                else
                    return vim.b[buf].autosave
                end
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
            "User IceLoad",
        },
        init = function()
            -- `matchparen.vim` needs to be disabled manually in case of lazy loading
            vim.g.loaded_matchparen = 1
        end,
        opts = {},
    },

    -- NOTE: 需要安装 im-select
    {
        "keaising/im-select.nvim",
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
                default_command = "macism"
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
                -- "VimEnter" and "FocusGained" were removed for causing problems, add it by your needs
                set_default_events = { "InsertLeave" },
            }
        end,
    },
}
