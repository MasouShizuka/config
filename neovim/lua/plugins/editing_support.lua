local buftype = require("utils.buftype")
local environment = require("utils.environment")
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
        config = function(_, opts)
            if not environment.is_vscode then
                opts["snippet_engine"] = "luasnip"
            end
            require("neogen").setup(opts)
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "<leader>gca", function() require("neogen").generate() end, desc = "Generate annotation", mode = { "n", "x" } },
        },
        opts = {},
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
            n_lines = math.huge,
        },
        version = false,
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
        version = false,
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
            mappings = {
                -- toggle = "gS",
                toggle = "gs",
            },
        },
        version = false,
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
        version = false,
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
                FIX = { icon = " ", color = "red", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = " ", color = "green" },
                HACK = { icon = " ", color = "orange" },
                WARN = { icon = " ", color = "yellow", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", color = "purple", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "blue", alt = { "INFO" } },
                TEST = { icon = " ", color = "cyan", alt = { "TESTING", "PASSED", "FAILED" } },
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
                keywords = keywords,
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
                highlight = {
                    keyword = "bg",
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
                -- history_length = 100,
                history_length = 0,
                -- storage = "shada",
                storage = "memory",
                sync_with_numbered_registers = true,
                cancel_event = "update",
            },
            picker = {
                select = {
                    action = nil, -- nil to use default put action
                },
                telescope = {
                    mappings = nil, -- nil to use default mappings
                },
            },
            system_clipboard = {
                sync_with_ring = true,
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
            doc_width = 80,
            box_width = 60,
            line_width = 58,
        },
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
            ---Add a space b/w comment and the line
            padding = true,
            ---Whether the cursor should stay at its position
            sticky = true,
            ---Lines to be ignored while (un)comment
            ignore = nil,
            ---LHS of toggle mappings in NORMAL mode
            toggler = {
                ---Line-comment toggle keymap
                line = "gcc",
                ---Block-comment toggle keymap
                -- block = "gbc",
                block = "gbb",
            },
            ---LHS of operator-pending mappings in NORMAL and VISUAL mode
            opleader = {
                ---Line-comment keymap
                line = "gc",
                ---Block-comment keymap
                block = "gb",
            },
            ---LHS of extra mappings
            extra = {
                ---Add comment on the line above
                above = "gcO",
                ---Add comment on the line below
                below = "gco",
                ---Add comment at the end of line
                eol = "gcA",
            },
            ---Enable keybindings
            ---NOTE: If given `false` then the plugin won't create any mappings
            mappings = {
                ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                basic = true,
                ---Extra mapping; `gco`, `gcO`, `gcA`
                extra = true,
            },
            ---Function to call before (un)comment
            pre_hook = nil,
            ---Function to call after (un)comment
            post_hook = nil,
        },
    },

    {
        "okuuva/auto-save.nvim",
        cmd = {
            "ASToggle",
        },
        config = function(_, opts)
            require("auto-save").setup(opts)

            local last_paste_start = vim.fn.getpos("'[")
            local last_paste_end = vim.fn.getpos("']")

            local group = vim.api.nvim_create_augroup("autosave", {})
            vim.api.nvim_create_autocmd("User", {
                callback = function(args)
                    if args.data.saved_buffer ~= nil then
                        local is_mini_trailspace_available, mini_trailspace = pcall(require, "mini.trailspace")
                        if is_mini_trailspace_available then
                            -- 新行不清空空格
                            if vim.api.nvim_get_current_line():match("^%s*$") == nil then
                                local trailspace_time = os.time()
                                if trailspace_time - vim.g.prev_trailspace_time > vim.g.trailspace_interval then
                                    mini_trailspace.trim()
                                    vim.g.prev_trailspace_time = trailspace_time
                                end
                            end
                        end

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
            condition = function(buf)
                local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                    return false
                end
                return true
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

    {
        "wingforth/nvim-im-select",
        enabled = environment.is_windows,
        event = {
            "InsertEnter",
        },
        opts = {
            -- im-select command, maybe the path to the executable `im-select`.
            -- default value : "im-select"
            im_select_cmd = "im-select",
            -- default input method for normal mode or others except insert.
            -- default value for macOS: "com.apple.keylayout.ABC".
            -- defalt value for Windows: "1033"
            default_im = "1033",
            -- enable or disable switch input method automatically on FocusLost and FocusGained events.
            -- disable by setting this option to false/0, or any other to enable.
            -- if you have set up other ways to switch IM among different windows/applications, you may want to set this option to false.
            -- default value is true.
            enable_on_focus_events = false,
        },
    },
}
