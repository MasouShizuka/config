local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        dir = path.config_path .. "/lua/config/options",
        lazy = false,
        name = "config.options",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/mappings",
        event = {
            "VeryLazy",
        },
        name = "config.mappings",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/autocommands/colorscheme-persist",
        enabled = not environment.is_vscode,
        event = {
            "UIEnter",
        },
        name = "config.autocommands.colorscheme-persist",
        opts = {},
        priority = 1000,
    },

    {
        dir = path.config_path .. "/lua/config/autocommands/macro-persist",
        event = {
            "RecordingLeave",
        },
        keys = {
            { "q", mode = "n" },
            { "@", mode = "n" },
        },
        name = "config.autocommands.macro-persist",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/autocommands/file-event",
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        name = "config.autocommands.file-event",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/autocommands/focus-left-tab-after-closing",
        enabled = not environment.is_vscode,
        event = {
            "QuitPre",
        },
        name = "config.autocommands.focus-left-tab-after-closing",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/autocommands/hlsearch",
        keys = {
            { "/", desc = "Search forward",  mode = { "n", "x" } },
            { "?", desc = "Search backward", mode = { "n", "x" } },
            { "*", desc = "Next",            mode = { "n", "x" } },
            { "#", desc = "Previous",        mode = { "n", "x" } },
        },
        name = "config.autocommands.hlsearch",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/autocommands/panel-synchronize",
        enabled = not environment.is_vscode,
        event = {
            "QuitPre",
            "TabLeave",
        },
        name = "config.autocommands.panel-synchronize",
        opts = {},
    },

    {
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
            "CBlline",
            "CBcline",
            "CBrline",
            "CBd",
            "CBy",
            "CBcatalog",
        },
        dir = path.config_path .. "/lua/config/user_commands/comment-box",
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            {
                                mode = { "n", "x" },
                                { "<leader>gc",  group = "comment box" },
                                { "<leader>gcb", group = "boxes" },
                                { "<leader>gct", group = "titled lines" },
                                { "<leader>gcl", group = "lines" },
                            },
                        })
                    end,
                    desc = "Register which-key for comment-box",
                    pattern = "IceLoad",
                })
            end
        end,
        keys = {
            { "<leader>gcbll", function() require("comment-box").box({ position = "left", justification = "left" }) end,                                              desc = "Left aligned box of fixed size with Left aligned text",   mode = { "n", "x" } },
            { "<leader>gcblc", function() require("comment-box").box({ position = "left", justification = "center" }) end,                                            desc = "Left aligned box of fixed size with Centered text",       mode = { "n", "x" } },
            { "<leader>gcblr", function() require("comment-box").box({ position = "left", justification = "right" }) end,                                             desc = "Left aligned box of fixed size with Right aligned text",  mode = { "n", "x" } },
            { "<leader>gcbcl", function() require("comment-box").box({ position = "center", justification = "left" }) end,                                            desc = "Centered box of fixed size with Left aligned text",       mode = { "n", "x" } },
            { "<leader>gcbcc", function() require("comment-box").box({ position = "center", justification = "center" }) end,                                          desc = "Centered box of fixed size with Centered text",           mode = { "n", "x" } },
            { "<leader>gcbcr", function() require("comment-box").box({ position = "center", justification = "right" }) end,                                           desc = "Centered box of fixed size with Right aligned text",      mode = { "n", "x" } },
            { "<leader>gcbrl", function() require("comment-box").box({ position = "right", justification = "left" }) end,                                             desc = "Right aligned box of fixed size with Left aligned text",  mode = { "n", "x" } },
            { "<leader>gcbrc", function() require("comment-box").box({ position = "right", justification = "center" }) end,                                           desc = "Right aligned box of fixed size with Centered text",      mode = { "n", "x" } },
            { "<leader>gcbrr", function() require("comment-box").box({ position = "right", justification = "right" }) end,                                            desc = "Right aligned box of fixed size with Right aligned text", mode = { "n", "x" } },
            { "<leader>gcbla", function() require("comment-box").box({ position = "left", justification = "adapted" }, { doc_width = 10000, box_width = 10000 }) end, desc = "Left aligned adapted box",                                mode = { "n", "x" } },
            { "<leader>gcbca", function() require("comment-box").box({ position = "center", justification = "adapted" }) end,                                         desc = "Centered adapted box",                                    mode = { "n", "x" } },
            { "<leader>gcbra", function() require("comment-box").box({ position = "right", justification = "adapted" }) end,                                          desc = "Right aligned adapted box",                               mode = { "n", "x" } },
            { "<leader>gctll", function() require("comment-box").titled_line({ position = "left", justification = "left" }) end,                                      desc = "Left aligned titled line with Left aligned text",         mode = { "n", "x" } },
            { "<leader>gctlc", function() require("comment-box").titled_line({ position = "left", justification = "center" }) end,                                    desc = "Left aligned titled line with Centered text",             mode = { "n", "x" } },
            { "<leader>gctlr", function() require("comment-box").titled_line({ position = "left", justification = "right" }) end,                                     desc = "Left aligned titled line with Right aligned text",        mode = { "n", "x" } },
            { "<leader>gctcl", function() require("comment-box").titled_line({ position = "center", justification = "left" }) end,                                    desc = "Centered titled line with Left aligned text",             mode = { "n", "x" } },
            { "<leader>gctcc", function() require("comment-box").titled_line({ position = "center", justification = "center" }) end,                                  desc = "Centered titled line with Centered text",                 mode = { "n", "x" } },
            { "<leader>gctcr", function() require("comment-box").titled_line({ position = "center", justification = "right" }) end,                                   desc = "Centered titled line with Right aligned text",            mode = { "n", "x" } },
            { "<leader>gctrl", function() require("comment-box").titled_line({ position = "right", justification = "left" }) end,                                     desc = "Right aligned titled line with Left aligned text",        mode = { "n", "x" } },
            { "<leader>gctrc", function() require("comment-box").titled_line({ position = "right", justification = "center" }) end,                                   desc = "Right aligned titled line with Centered text",            mode = { "n", "x" } },
            { "<leader>gctrr", function() require("comment-box").titled_line({ position = "right", justification = "right" }) end,                                    desc = "Right aligned titled line with Right aligned text",       mode = { "n", "x" } },
            { "<leader>gcll",  function() require("comment-box").line({ position = "left" }) end,                                                                     desc = "Left aligned line",                                       mode = { "n", "x" } },
            { "<leader>gclc",  function() require("comment-box").line({ position = "center" }) end,                                                                   desc = "Centered line",                                           mode = { "n", "x" } },
            { "<leader>gclr",  function() require("comment-box").line({ position = "right" }) end,                                                                    desc = "Right aligned line",                                      mode = { "n", "x" } },
            { "<leader>gcd",   function() require("comment-box").dbox() end,                                                                                          desc = "Remove a box or titled line, keeping its content",        mode = { "n", "x" } },
            { "<leader>gcy",   function() require("comment-box").yank() end,                                                                                          desc = "Yank the content of a box or titled line",                mode = { "n", "x" } },
        },
        name = "config.user_commands.comment-box",
        opts = {
            keep_indent = true,
        },
    },

    {
        cmd = {
            "DiffWithClipboard",
            "DiffWithNextTab",
            "DiffWithPrevTab",
        },
        dir = path.config_path .. "/lua/config/user_commands/diff",
        enabled = not environment.is_vscode,
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>cd", group = "diff", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for diff",
                    pattern = "IceLoad",
                })
            end
        end,
        keys = {
            { "<leader>cdc", function() require("diff").diff_with_clipboard() end,    desc = "Diff with clipboard",    mode = "n" },
            { "<leader>cdn", function() require("diff").diff_with_next_tab() end,     desc = "Diff with next tab",     mode = "n" },
            { "<leader>cdp", function() require("diff").diff_with_previous_tab() end, desc = "Diff with previous tab", mode = "n" },
        },
        name = "config.user_commands.diff",
        opts = {},
    },

    {
        cmd = {
            "FencAutoDetect",
            "FencView",
        },
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>cf", group = "fencview", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for fencview",
                    pattern = "IceLoad",
                })
            end
        end,
        keys = {
            { "<leader>cff", function() require("fencview").autodetect() end,  desc = "Auto detect encoding", mode = "n" },
            { "<leader>cfv", function() require("fencview").toggle_view() end, desc = "Toggle encoding",      mode = "n" },
        },
        dir = path.config_path .. "/lua/config/user_commands/fencview",
        enabled = not environment.is_vscode,
        name = "config.user_commands.fencview",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/user_commands/toggle",
        init = function()
            local utils = require("utils")

            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>ct", group = "toggle", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for toggle",
                    pattern = "IceLoad",
                })
            end

            utils.create_once_autocmd("User", {
                callback = function()
                    utils.set_setting_toggle("cursor_center", {
                        default = false,
                        g = {
                            keymap = { keys = "<leader>ctc", mode = "n" },
                        },
                        b = {
                            keymap = { keys = "<leader>ctC", mode = "n" },
                        },
                    })

                    if environment.is_vscode then
                        vim.keymap.set("n", "<leader>ctf", function()
                            if not package.loaded["toggle"] then
                                require("lazy").load({ plugins = "config.user_commands.toggle" })
                            end
                            require("toggle").vscode.toggle_fileformat()
                        end, { desc = "Toggle fileformat", silent = true })
                        vim.keymap.set("n", "<leader>ctw", function()
                            if not package.loaded["toggle"] then
                                require("lazy").load({ plugins = "config.user_commands.toggle" })
                            end
                            require("toggle").vscode.toggle_wrap()
                        end, { desc = "Toggle wrap", silent = true })
                    else
                        if utils.is_available("snacks.nvim") then
                            local snacks = require("snacks")

                            snacks.toggle.new({
                                id = "fileformat",
                                name = "fileformat",
                                get = function()
                                    local on = "unix"
                                    if environment.is_windows then
                                        on = "dos"
                                    end
                                    return vim.api.nvim_get_option_value("fileformat", { scope = "local" }) == on
                                end,
                                set = function()
                                    if not package.loaded["toggle"] then
                                        require("lazy").load({ plugins = "config.user_commands.toggle" })
                                    end
                                    require("toggle").nvim.toggle_fileformat({ notify = false })
                                end,
                            }):map("<leader>ctf")
                            snacks.toggle.new({
                                id = "syntax",
                                name = "syntax",
                                get = function()
                                    local syntax = vim.api.nvim_get_option_value("syntax", { scope = "local" })
                                    if syntax ~= "on" and syntax ~= "off" then
                                        syntax = "on"
                                    end
                                    return syntax == "on"
                                end,
                                set = function()
                                    if not package.loaded["toggle"] then
                                        require("lazy").load({ plugins = "config.user_commands.toggle" })
                                    end
                                    require("toggle").nvim.toggle_syntax({ notify = false })
                                end,
                            }):map("<leader>ctt")

                            snacks.toggle.option("spell"):map("<leader>cts")
                            snacks.toggle.option("wrap"):map("<leader>ctw")
                        else
                            vim.keymap.set("n", "<leader>ctf", function() require("toggle").nvim.toggle_fileformat() end, { desc = "Toggle fileformat", silent = true })
                            vim.keymap.set("n", "<leader>cts", function() require("toggle").nvim.toggle_spell() end, { desc = "Toggle spell", silent = true })
                            vim.keymap.set("n", "<leader>ctt", function() require("toggle").nvim.toggle_syntax() end, { desc = "Toggle syntax", silent = true })
                            vim.keymap.set("n", "<leader>ctw", function() require("toggle").nvim.toggle_wrap() end, { desc = "Toggle wrap", silent = true })
                        end
                    end
                end,
                desc = "Toggle toggle",
                pattern = "IceLoad",
            })
        end,
        name = "config.user_commands.toggle",
        opts = {},
    },

    {
        cmd = {
            "Undoquit",
            "UndoquitTab",
        },
        dir = path.config_path .. "/lua/config/user_commands/undoquit",
        enabled = not environment.is_vscode,
        event = {
            "QuitPre",
        },
        keys = function()
            local keymap = require("utils.keymap")

            return {
                { keymap["<c-s-t>"],               function() require("undoquit").restore_window() end, desc = "Undo quit",     mode = "n" },
                { "<leader>" .. keymap["<c-s-t>"], function() require("undoquit").restore_tab() end,    desc = "Undo quit tab", mode = "n" },
            }
        end,
        name = "config.user_commands.undoquit",
        opts = {},
    },

    {
        cmd = {
            "WindowsMaximize",
            "WindowsMaximizeVertical",
            "WindowsMaximizeHorizont",
            "WindowsEqualize",
            "WindowsToggleAutowidth",
        },
        dir = path.config_path .. "/lua/config/user_commands/windows",
        enabled = not environment.is_vscode,
        event = {
            "User IceLoad",
        },
        keys = {
            { "<c-s><c-m>", function() vim.api.nvim_command("WindowsMaximize") end,             desc = "Maximize current window",                 mode = "n" },
            { "<c-s><c-c>", function() vim.api.nvim_command("WindowsMaximizeVertically") end,   desc = "Maximize height of the current window",   mode = "n" },
            { "<c-s><c-r>", function() vim.api.nvim_command("WindowsMaximizeHorizontally") end, desc = "Maximize width of the current window",    mode = "n" },
            { "<c-s><c-e>", function() vim.api.nvim_command("WindowsEqualize") end,             desc = "Equalize all windows heights and widths", mode = "n" },
            { "<c-s><c-t>", function() vim.api.nvim_command("WindowsToggleAutowidth") end,      desc = "Toggle auto-width feature",               mode = "n" },
        },
        name = "config.user_commands.windows",
        opts = function()
            return {
                ignore = {
                    buftype = require("utils.buftype").skip_buftype_list,
                    filetype = require("utils.filetype").skip_filetype_list,
                },
                animation = {
                    enable = false,
                },
            }
        end,
    },
}
