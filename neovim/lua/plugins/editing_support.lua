local buftype = require("utils.buftype")
local environment = require("utils.environment")
local icons = require("utils.icons")
local utils = require("utils")

return {
    {
        "altermo/ultimate-autopair.nvim",
        config = function(_, opts)
            require("ultimate-autopair").setup(opts)

            -- 新行保持缩进
            vim.keymap.set("i", "<cr>", function()
                local core = require("ultimate-autopair.core")
                return core.run(vim.api.nvim_replace_termcodes("<cr>", true, true, true)) .. core.run(vim.api.nvim_replace_termcodes("x<bs>", true, true, true))
            end, { desc = "Enter", expr = true, replace_keycodes = false })
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
        config = function(_, opts)
            require("mini.ai").setup(opts)
        end,
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
            -- nvim-treesitter-textobjects
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
                [","] = { "<().-()>" },
                ["."] = { "<().-()>" },
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
        config = function(_, opts)
            require("mini.operators").setup(opts)
        end,
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
        "echasnovski/mini.splitjoin",
        config = function(_, opts)
            require("mini.splitjoin").setup(opts)
        end,
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
    {
        "echasnovski/mini.trailspace",
        config = function(_, opts)
            require("mini.trailspace").setup(opts)
        end,
        init = function()
            if environment.is_vscode then
                vim.api.nvim_create_autocmd("InsertLeave", {
                    callback = function()
                        -- 新行不清空空格
                        if vim.api.nvim_get_current_line():match("^%s*$") == nil then
                            require("mini.trailspace").trim()
                        end
                    end,
                    desc = "Trail space when insert leave",
                    group = vim.api.nvim_create_augroup("TrailSpace", { clear = true }),
                })
            end
        end,
        lazy = true,
    },

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
            "User TreesitterFile",
        },
        keys = {
            { "<leader>xt", function() vim.api.nvim_command("TodoTrouble") end, desc = "List all project todos in trouble", mode = "n" },
        },
        opts = function()
            local keywords = {
                FIX = { icon = icons.misc.bug, color = "red", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = icons.misc.check, color = "green" },
                HACK = { icon = icons.misc.flame, color = "orange" },
                WARN = { icon = icons.diagnostics.Warn, color = "yellow", alt = { "WARNING", "XXX" } },
                PERF = { icon = icons.misc.clock, color = "purple", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = icons.diagnostics.Info, color = "blue", alt = { "INFO" } },
                TEST = { icon = icons.misc.beaker, color = "cyan", alt = { "TESTING", "PASSED", "FAILED" } },
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
                    keyword = "bg",
                },
                -- list of named colors where we try to extract the guifg from the
                -- list of highlight groups or use the hex color if hl not found as a fallback
                colors = {
                    red = { "DiagnosticError", "ErrorMsg", "#e06c75" },
                    green = { "String", "#98c379" },
                    orange = { "Constant", "#d19a66" },
                    yellow = { "DiagnosticWarn", "WarningMsg", "#e5c07b" },
                    purple = { "Statement", "#c678dd" },
                    blue = { "DiagnosticInfo", "#61afef" },
                    cyan = { "DiagnosticHint", "#56b6c2" },
                    default = { "NonText", "#5c6370" },
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
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 500,
            },
            preserve_cursor_position = {
                enabled = true,
            },
        },
    },

    {
        "HiPhish/rainbow-delimiters.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not environment.is_vscode,
        event = {
            "User TreesitterFile",
        },
    },

    {
        "LudoPinelli/comment-box.nvim",
        cmd = {
            "CBllbox",
            "CBlcbox",
            "CBlrbox",
            "CBclbox",
            "CBccbox",
            "CBcrbox",
            "CBrlbox",
            "CBrcbox",
            "CBrrbox",
            "CBlabox",
            "CBcabox",
            "CBrabox",
            "CBllline",
            "CBlcline",
            "CBlrline",
            "CBclline",
            "CBccline",
            "CBcrline",
            "CBrlline",
            "CBrcline",
            "CBrrline",
            "CBline",
            "CBcline",
            "CBrline",
            "CBd",
            "CBy",
            "CBcatalog",
        },
        init = function()
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
                    mode = { "n", "x" },
                    ["<leader>gcb"] = {
                        name = "+boxes",
                    },
                    ["<leader>gct"] = {
                        name = "+titled lines",
                    },
                    ["<leader>gcl"] = {
                        name = "+lines",
                    },
                })
            end
        end,
        keys = {
            { "<leader>gcbll", function() require("comment-box").llbox() end,  desc = "Left aligned box of fixed size with Left aligned text",   mode = { "n", "x" } },
            { "<leader>gcblc", function() require("comment-box").lcbox() end,  desc = "Left aligned box of fixed size with Centered text",       mode = { "n", "x" } },
            { "<leader>gcblr", function() require("comment-box").lrbox() end,  desc = "Left aligned box of fixed size with Right aligned text",  mode = { "n", "x" } },
            { "<leader>gcbcl", function() require("comment-box").clbox() end,  desc = "Centered box of fixed size with Left aligned text",       mode = { "n", "x" } },
            { "<leader>gcbcc", function() require("comment-box").ccbox() end,  desc = "Centered box of fixed size with Centered text",           mode = { "n", "x" } },
            { "<leader>gcbcr", function() require("comment-box").crbox() end,  desc = "Centered box of fixed size with Right aligned text",      mode = { "n", "x" } },
            { "<leader>gcbrl", function() require("comment-box").rlbox() end,  desc = "Right aligned box of fixed size with Left aligned text",  mode = { "n", "x" } },
            { "<leader>gcbrc", function() require("comment-box").rcbox() end,  desc = "Right aligned box of fixed size with Centered text",      mode = { "n", "x" } },
            { "<leader>gcbrr", function() require("comment-box").rrbox() end,  desc = "Right aligned box of fixed size with Right aligned text", mode = { "n", "x" } },
            { "<leader>gcbla", function() require("comment-box").labox() end,  desc = "Left aligned adapted box",                                mode = { "n", "x" } },
            { "<leader>gcbca", function() require("comment-box").cabox() end,  desc = "Centered adapted box",                                    mode = { "n", "x" } },
            { "<leader>gcbra", function() require("comment-box").rabox() end,  desc = "Right aligned adapted box",                               mode = { "n", "x" } },
            { "<leader>gctll", function() require("comment-box").llline() end, desc = "Left aligned titled line with Left aligned text",         mode = { "n", "x" } },
            { "<leader>gctlc", function() require("comment-box").lcline() end, desc = "Left aligned titled line with Centered text",             mode = { "n", "x" } },
            { "<leader>gctlr", function() require("comment-box").lrline() end, desc = "Left aligned titled line with Right aligned text",        mode = { "n", "x" } },
            { "<leader>gctcl", function() require("comment-box").clline() end, desc = "Centered titled line with Left aligned text",             mode = { "n", "x" } },
            { "<leader>gctcc", function() require("comment-box").ccline() end, desc = "Centered titled line with Centered text",                 mode = { "n", "x" } },
            { "<leader>gctcr", function() require("comment-box").crline() end, desc = "Centered titled line with Right aligned text",            mode = { "n", "x" } },
            { "<leader>gctrl", function() require("comment-box").rlline() end, desc = "Right aligned titled line with Left aligned text",        mode = { "n", "x" } },
            { "<leader>gctrc", function() require("comment-box").rcline() end, desc = "Right aligned titled line with Centered text",            mode = { "n", "x" } },
            { "<leader>gctrr", function() require("comment-box").rrline() end, desc = "Right aligned titled line with Right aligned text",       mode = { "n", "x" } },
            { "<leader>gcd",   function() require("comment-box").dbox() end,   desc = "Remove a box or titled line, keeping its content",        mode = { "n", "x" } },
            { "<leader>gcy",   function() require("comment-box").yank() end,   desc = "Yank the content of a box or titled line",                mode = { "n", "x" } },
            { "<leader>gcll",  function() require("comment-box").line() end,   desc = "Left aligned line",                                       mode = { "n", "x" } },
            { "<leader>gclc",  function() require("comment-box").cline() end,  desc = "Centered line",                                           mode = { "n", "x" } },
            { "<leader>gclr",  function() require("comment-box").rline() end,  desc = "Right aligned line",                                      mode = { "n", "x" } },
        },
        opts = {
            doc_width = 80,  -- width of the document
            box_width = 60,  -- width of the boxes
            line_width = 60, -- width of the lines
        },
    },

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
                default_im_select       = default_im_select,

                -- Can be binary's name or binary's full path,
                -- e.g. 'im-select' or '/usr/local/bin/im-select'
                -- For Windows/WSL, default: "im-select.exe"
                -- For macOS, default: "im-select"
                -- For Linux, default: "fcitx5-remote" or "fcitx-remote" or "ibus"
                default_command         = default_command,

                -- Restore the default input method state when the following events are triggered
                -- set_default_events      = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
                set_default_events      = { "InsertLeave" },

                -- Restore the previous used input method state when the following events
                -- are triggered, if you don't want to restore previous used im in Insert mode,
                -- e.g. deprecated `disable_auto_restore = 1`, just let it empty
                -- as `set_previous_events = {}`
                set_previous_events     = { "InsertEnter" },

                -- Show notification about how to install executable binary when binary missed
                keep_quiet_on_no_binary = false,

                -- Async run `default_command` to switch IM or not
                async_switch_im         = true,
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

                local cstr = F.get(vim.bo.filetype, ctx.ctype)
                local lcs, rcs = U.unwrap_cstr(cstr)
                lcs = utils.escape(lcs)
                rcs = utils.escape(rcs)
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

            local function trailspace()
                if not utils.is_available("mini.trailspace") then
                    return
                end

                local is_mini_trailspace_available, mini_trailspace = pcall(require, "mini.trailspace")
                if not is_mini_trailspace_available then
                    return
                end

                -- 新行不清空尾随空格
                if vim.api.nvim_get_current_line():match("^%s*$") ~= nil then
                    return
                end

                -- 当处于 LuaSnip 的 snippet 时，不清空尾随空格
                if utils.is_available("LuaSnip") then
                    local luasnip = require("luasnip")
                    if luasnip.in_snippet() then
                        return
                    end
                end

                -- 间隔小于指定间隔时，不清空尾随空格
                local trailspace_time = os.time()
                if trailspace_time - vim.g.prev_trailspace_time <= vim.g.trailspace_interval then
                    return
                end

                mini_trailspace.trim()
                vim.g.prev_trailspace_time = trailspace_time
            end

            local last_paste_start = vim.fn.getpos("'[")
            local last_paste_end = vim.fn.getpos("']")

            local group = vim.api.nvim_create_augroup("autosave", {})
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
                group = group,
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
                group = group,
                desc = "AutoSaveWritePost event",
                pattern = "AutoSaveWritePost",
            })

            if vim.g.autosave_enabled == nil then
                vim.g.autosave_enabled = true
            end

            vim.keymap.set("n", "<leader>cta", function() utils.toggle_global_setting("autosave_enabled", function(global_enabled, prev_enabled, enabled) end) end, { desc = "Toggle autoSave", silent = true })
            vim.keymap.set("n", "<leader>ctA", function() utils.toggle_buffer_setting("autosave_enabled", function(prev_enabled, enabled) end) end, { desc = "Toggle autoSave (buffer)", silent = true })
        end,
        enabled = not environment.is_vscode,
        event = {
            "User AutoSave",
        },
        init = function()
            vim.g.trailspace_interval = 3
            vim.g.prev_trailspace_time = os.time()

            vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertLeave", "TextChanged" }, {
                callback = function(args)
                    local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
                    local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = args.buf })
                    local is_modified = vim.api.nvim_get_option_value("modified", { buf = args.buf })
                    if not vim.tbl_contains(buftype.skip_buftype_list, bt) and is_modifiable and is_modified then
                        pcall(vim.cmd.write)
                        utils.event("AutoSave")
                        vim.api.nvim_del_augroup_by_name("AutoSave")
                    end
                end,
                desc = "AutoSave event",
                group = vim.api.nvim_create_augroup("AutoSave", { clear = true }),
            })
        end,
        opts = {
            execution_message = {
                enabled = false,
            },
            trigger_events = {                                 -- See :h events
                immediate_save = { "BufLeave", "FocusLost" },  -- vim events that trigger an immediate save
                defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
                cancel_defered_save = { "InsertEnter" },       -- vim events that cancel a pending deferred save
            },
            -- function that takes the buffer handle and determines whether to save the current buffer or not
            -- return true: if buffer is ok to be saved
            -- return false: if it's not ok to be saved
            -- if set to `nil` then no specific condition is applied
            condition = function(buf)
                local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                    return false
                end

                if vim.b[buf].autosave_enabled ~= nil then
                    return vim.b[buf].autosave_enabled
                else
                    return vim.g.autosave_enabled
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
            "BufNewFile",
            "BufReadPost",
        },
        init = function()
            -- `matchparen.vim` needs to be disabled manually in case of lazy loading
            vim.g.loaded_matchparen = 1
        end,
        opts = {},
        version = "*",
    },
}
