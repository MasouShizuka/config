local buftype = require("utils.buftype")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local keymap = require("utils.keymap")
local path = require("utils.path")
local utils = require("utils")

return {
    {
        dir = path.config_path .. "/lua/config/options",
        lazy = false,
        name = "config.options",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/neovide",
        enabled = environment.is_neovide,
        lazy = false,
        name = "config.neovide",
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
        lazy = false,
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
            "BufNewFile",
            "BufReadPre",
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
            { "n", desc = "Next",            mode = { "n", "x" } },
            { "N", desc = "Previous",        mode = { "n", "x" } },
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
            if utils.is_available("which-key.nvim") then
                require("which-key").add({
                    {
                        mode = { "n", "x" },
                        { "<leader>gc",  group = "comment box" },
                        { "<leader>gcb", group = "boxes" },
                        { "<leader>gct", group = "titled lines" },
                        { "<leader>gcl", group = "lines" },
                    },
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
            if utils.is_available("which-key.nvim") then
                require("which-key").add({
                    { "<leader>cd", group = "diff", mode = "n" },
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
            "DocsViewToggle",
        },
        config = function(_, opts)
            local extra_view = require("extra-view")
            extra_view.setup(opts)

            vim.api.nvim_create_user_command("DocsViewToggle", function()
                extra_view.extra_view_toggle(function(buf, win)
                    if filetype.is_panel_filetype(vim.bo.filetype) then
                        return
                    end

                    local gotHover = false
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        if client.supports_method("textDocument/hover") then
                            gotHover = true
                            break
                        end
                    end
                    if not gotHover then
                        return
                    end

                    vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(err, result, ctx, config)
                        if win and vim.api.nvim_win_is_valid(win) and result and result.contents then
                            local md_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
                            if vim.tbl_isempty(md_lines) then
                                return
                            end

                            vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
                            vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
                            vim.lsp.util.stylize_markdown(buf, md_lines)
                            vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
                        end
                    end)
                end, {
                    filetype = "nvim-docs-view",
                })
            end, { desc = "Toggle nvim-docs-view" })
        end,
        dir = path.config_path .. "/lua/config/user_commands/extra-view",
        enabled = not environment.is_vscode,
        name = "config.user_commands.extra-view",
        opts = {},
    },

    {
        dir = path.config_path .. "/lua/config/user_commands/toggle",
        init = function()
            if utils.is_available("which-key.nvim") then
                require("which-key").add({
                    { "<leader>ct", group = "toggle", mode = "n" },
                })
            end
        end,
        keys = function()
            local keys = {}
            if environment.is_vscode then
                vim.list_extend(keys, {
                    { "<leader>ctc", function() require("toggle").vscode.toggle_cursor_center() end,     desc = "Toggle cursor center",          mode = "n" },
                    { "<leader>ctC", function() require("toggle").vscode.toggle_cursor_center(true) end, desc = "Toggle cursor center (buffer)", mode = "n" },
                    { "<leader>ctf", function() require("toggle").vscode.toggle_fileformat() end,        desc = "Toggle fileformat",             mode = "n" },
                    { "<leader>ctw", function() require("toggle").vscode.toggle_wrap() end,              desc = "Toggle wrap",                   mode = "n" },
                })
            else
                vim.list_extend(keys, {
                    { "<leader>ctc", function() require("toggle").nvim.toggle_cursor_center() end,     desc = "Toggle cursor center",          mode = "n" },
                    { "<leader>ctC", function() require("toggle").nvim.toggle_cursor_center(true) end, desc = "Toggle cursor center (buffer)", mode = "n" },
                    { "<leader>ctf", function() require("toggle").nvim.toggle_fileformat() end,        desc = "Toggle fileformat",             mode = "n" },
                    { "<leader>cts", function() require("toggle").nvim.toggle_spell() end,             desc = "Toggle spell",                  mode = "n" },
                    { "<leader>ctS", function() require("toggle").nvim.toggle_syntax() end,            desc = "Toggle syntax",                 mode = "n" },
                    { "<leader>ctw", function() require("toggle").nvim.toggle_wrap() end,              desc = "Toggle wrap",                   mode = "n" },
                })
            end
            return keys
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
        keys = {
            { keymap["<c-s-t>"],               function() require("undoquit").restore_window() end, desc = "Undo quit",     mode = "n" },
            { "<leader>" .. keymap["<c-s-t>"], function() require("undoquit").restore_tab() end,    desc = "Undo quit tab", mode = "n" },
        },
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
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "<c-s><c-m>", function() vim.api.nvim_command("WindowsMaximize") end,             desc = "Maximize current window",                 mode = "n" },
            { "<c-s><c-c>", function() vim.api.nvim_command("WindowsMaximizeVertically") end,   desc = "Maximize height of the current window",   mode = "n" },
            { "<c-s><c-r>", function() vim.api.nvim_command("WindowsMaximizeHorizontally") end, desc = "Maximize width of the current window",    mode = "n" },
            { "<c-s><c-e>", function() vim.api.nvim_command("WindowsEqualize") end,             desc = "Equalize all windows heights and widths", mode = "n" },
            { "<c-s><c-t>", function() vim.api.nvim_command("WindowsToggleAutowidth") end,      desc = "Toggle auto-width feature",               mode = "n" },
        },
        name = "config.user_commands.windows",
        opts = {
            ignore = {
                buftype = buftype.skip_buftype_list,
                filetype = filetype.skip_filetype_list,
            },
            animation = {
                enable = false,
            },
        },
    },
}
