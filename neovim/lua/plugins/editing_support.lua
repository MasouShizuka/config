local variables = require("config.variables")

return {
    {
        "https://git.sr.ht/~nedia/auto-save.nvim",
        dependencies = {
            "echasnovski/mini.trailspace",
        },
        enabled = not variables.is_vscode,
        event = {
            "BufLeave",
            "FocusLost",
            "InsertLeave",
            "TextChanged",
        },
        init = function()
            vim.g.trailspace_interval = 3
            vim.g.prev_trailspace_time = os.time()
        end,
        opts = {
            -- The name of the augroup.
            augroup_name = "AutoSavePlug",
            -- The events in which to trigger an auto save.
            -- events = { "InsertLeave", "TextChanged" },
            events = { "BufLeave", "FocusLost", "InsertLeave", "TextChanged" },
            -- If you'd prefer to silence the output of `save_fn`.
            silent = true,
            -- If you'd prefer to write a vim command.
            save_cmd = nil,
            -- What to do after checking if auto save conditions have been met.
            save_fn = function()
                -- 新行不清空空格
                if string.match(vim.api.nvim_get_current_line(), "^%s*$") == nil then
                    local trailspace_time = os.time()
                    if trailspace_time - vim.g.prev_trailspace_time > vim.g.trailspace_interval then
                        require("mini.trailspace").trim()
                        vim.g.prev_trailspace_time = trailspace_time
                    end
                end

                -- 保存文件前保存上次复制的范围
                local last_paste_start = vim.fn.getpos("'[")
                local last_paste_end = vim.fn.getpos("']")


                local config = require("auto-save.config")
                if config.save_cmd ~= nil then
                    vim.api.nvim_command(config.save_cmd)
                elseif config.silent then
                    vim.api.nvim_command("silent! w")
                else
                    vim.api.nvim_command("w")
                end

                -- 读取上次复制的范围
                vim.fn.setpos("'[", last_paste_start)
                vim.fn.setpos("']", last_paste_end)
            end,
            -- May define a timeout, or a duration to defer the save for - this allows
            -- for formatters to run, for example if they're configured via an autocmd
            -- that listens for `BufWritePre` event.
            timeout = 1,
            -- Define some filetypes to explicitly not save, in case our existing conditions
            -- don't quite catch all the buffers we'd prefer not to write to.
            exclude_ft = {},
        },
    },

    {
        "altermo/ultimate-autopair.nvim",
        config = function(_, opts)
            require("ultimate-autopair").setup(opts)

            -- 新行保持缩进
            vim.keymap.set("i", "<cr>", function()
                return require("ultimate-autopair.core").run("<cr>x<bs>")
            end, { desc = "Enter", expr = true, replace_keycodes = false })
        end,
        enabled = not variables.is_vscode,
        event = {
            "InsertEnter",
            "CmdlineEnter",
        },
        opts = {
            space = {
                enable = false,
            },
        },
    },

    {
        "chrisgrieser/nvim-alt-substitute",
        enabled = not variables.is_vscode,
        keys = {
            { "<c-f>", ":S ///g<left><left><left>", desc = "AltSubstitute", mode = { "n", "x" } },
        },
        opts = {
            showNotification = true, -- whether to show the "x replacements made" notification
        },
    },

    {
        "echasnovski/mini.ai",
        config = function(_, opts)
            require("mini.ai").setup(opts)
        end,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {
            custom_textobjects = {
                a = { "<().-()>" },
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
            n_lines = 500,
        },
        version = false,
    },
    {
        "echasnovski/mini.operators",
        config = function(_, opts)
            require("mini.operators").setup(opts)
        end,
        keys = {
            { "se", desc = "Evaluate text and replace with output", mode = { "n", "x" } },
            { "sx", desc = "Exchange text regions",                 mode = { "n", "x" } },
            { "sm", desc = "Multiply (duplicate) text",             mode = { "n", "x" } },
            { "ss", desc = "Replace text with register",            mode = { "n", "x" } },
            { "sS", desc = "Sort text",                             mode = { "n", "x" } },
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

            if variables.is_vscode then
                vim.api.nvim_create_autocmd("InsertLeave", {
                    callback = function()
                        -- 新行不清空空格
                        if string.match(vim.api.nvim_get_current_line(), "^%s*$") == nil then
                            require("mini.trailspace").trim()
                        end
                    end,
                    desc = "Trail space when insert leave",
                    group = vim.api.nvim_create_augroup("TrailSpace", { clear = true }),
                    pattern = "*",
                })
            end
        end,
        version = false,
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
        "keaising/im-select.nvim",
        enabled = variables.is_windows,
        event = {
            "InsertEnter",
        },
        opts = {
            -- IM will be set to `default_im_select` in `normal` mode
            -- For Windows/WSL, default: "1033", aka: English US Keyboard
            -- For macOS, default: "com.apple.keylayout.ABC", aka: US
            -- For Linux, default: "keyboard-us" for Fcitx5 or "1" for Fcitx or "xkb:us::eng" for ibus
            -- You can use `im-select` or `fcitx5-remote -n` to get the IM's name you preferred
            default_im_select = "1033",

            -- Can be binary's name or binary's full path,
            -- e.g. 'im-select' or '/usr/local/bin/im-select'
            -- For Windows/WSL, default: "im-select.exe"
            -- For macOS, default: "im-select"
            -- For Linux, default: "fcitx5-remote" or "fcitx-remote" or "ibus"
            -- default_command = vim.fn.stdpath("config") .. "/im-select",
            default_command = "im-select",

            -- Restore the default input method state when the following events are triggered
            -- set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
            set_default_events = { "InsertLeave" },

            -- Restore the previous used input method state when the following events are triggered
            -- if you don't want to restore previous used im in Insert mode,
            -- e.g. deprecated `disable_auto_restore = 1`, just let it empty `set_previous_events = {}`
            set_previous_events = { "InsertEnter" },

            -- Show notification about how to install executable binary when binary is missing
            keep_quiet_on_no_binary = false,
        },
    },

    {
        "monaqa/dial.nvim",
        config = function()
            local augend = require("dial.augend")
            require("dial.config").augends:register_group({
                default = {
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

                    augend.integer.alias.binary,
                    augend.integer.alias.decimal_int,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,

                    augend.semver.alias.semver,
                },
            })
        end,
        keys = {
            { "<c-a>",  function() return require("dial.map").inc_normal() end,  desc = "Increase", expr = true, mode = "n" },
            { "<c-x>",  function() return require("dial.map").dec_normal() end,  desc = "Decrease", expr = true, mode = "n" },
            { "<c-a>",  function() return require("dial.map").inc_visual() end,  desc = "Increase", expr = true, mode = "x" },
            { "<c-x>",  function() return require("dial.map").dec_visual() end,  desc = "Decrease", expr = true, mode = "x" },
            { "g<c-a>", function() return require("dial.map").inc_gvisual() end, desc = "Increase", expr = true, mode = "x" },
            { "g<c-x>", function() return require("dial.map").dec_gvisual() end, desc = "Decrease", expr = true, mode = "x" },
        },
    },

    {
        "numToStr/Comment.nvim",
        enabled = not variables.is_vscode,
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
        "utilyre/sentiment.nvim",
        enabled = not variables.is_vscode,
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
