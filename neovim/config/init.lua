local environment = require("utils.environment")
local keymap = require("utils.keymap")
local path = require("utils.path")
local utils = require("utils")

-- Bootstrap lazy.nvim
local lazypath = path.data_path .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>z", function() require("lazy").home() end, { desc = "Lazy", silent = true })

-- Setup lazy.nvim
return require("lazy").setup({
    spec = {
        -- import your plugins
        { import = "plugins" },

        {
            config = function(_, opts)
                require("config.options").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/options",
            lazy = false,
            name = "config.options",
            opts = {},
        },

        {
            config = function(_, opts)
                require("config.neovide").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/neovide",
            enabled = environment.is_neovide,
            lazy = false,
            name = "config.neovide",
            opts = {},
        },

        {
            config = function(_, opts)
                require("config.mappings").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/mappings",
            event = {
                "VeryLazy",
            },
            name = "config.mappings",
            opts = {},
        },

        {
            config = function(_, opts)
                require("config.autocommands.colorscheme-persist").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/autocommands/colorscheme-persist",
            enabled = not environment.is_vscode,
            lazy = false,
            name = "config.autocommands.colorscheme-persist",
            opts = {},
            priority = 1000,
        },

        {
            config = function(_, opts)
                require("config.autocommands.macro-persist").setup(opts)
            end,
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
            config = function(_, opts)
                require("config.autocommands.file-event").setup(opts)
            end,
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
            config = function(_, opts)
                require("config.autocommands.focus-left-tab-after-closing").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/autocommands/focus-left-tab-after-closing",
            enabled = not environment.is_vscode,
            event = {
                "QuitPre",
            },
            name = "config.autocommands.focus-left-tab-after-closing",
            opts = {},
        },

        {
            config = function(_, opts)
                require("config.autocommands.panel-synchronize").setup(opts)
            end,
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
                "DiffWithClipboard",
                "DiffWithNextTab",
                "DiffWithPrevTab",
            },
            config = function(_, opts)
                require("config.user_commands.diff").setup(opts)
            end,
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
                { "<leader>cdc", function() require("config.user_commands.diff").diff_with_clipboard() end,    desc = "Diff with clipboard",    mode = "n" },
                { "<leader>cdn", function() require("config.user_commands.diff").diff_with_next_tab() end,     desc = "Diff with next tab",     mode = "n" },
                { "<leader>cdp", function() require("config.user_commands.diff").diff_with_previous_tab() end, desc = "Diff with previous tab", mode = "n" },
            },
            name = "config.user_commands.diff",
            opts = {},
        },

        {
            cmd = {
                "DocsViewToggle",
            },
            config = function(_, opts)
                local extra_view = require("config.user_commands.extra-view")
                extra_view.setup(opts)

                vim.api.nvim_create_user_command("DocsViewToggle", function()
                    extra_view.extra_view_toggle(function(buf, win)
                        local can_hover = false
                        for _, client in ipairs(vim.lsp.get_clients()) do
                            if client.supports_method("textDocument/hover") then
                                can_hover = true
                                break
                            end
                        end
                        if not can_hover then
                            return
                        end

                        vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(err, result, ctx, config)
                            if win and vim.api.nvim_win_is_valid(win) and result and result.contents then
                                local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
                                if vim.tbl_isempty(markdown_lines) then
                                    return
                                end

                                vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
                                vim.api.nvim_buf_set_lines(buf, 0, -1, true, {})
                                vim.lsp.util.stylize_markdown(buf, markdown_lines, {})
                                vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
                            end
                        end)
                    end, {
                        filetype = "nvim-docs-view",
                        position = "right",
                    })
                end, { desc = "Toggle nvim-docs-view" })
            end,
            dir = path.config_path .. "/lua/config/user_commands/extra-view",
            enabled = not environment.is_vscode,
            name = "config.user_commands.extra-view",
            opts = {},
        },

        {
            config = function(_, opts)
                require("config.user_commands.toggle").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/user_commands/toggle",
            init = function()
                if utils.is_available("which-key.nvim") then
                    require("which-key").add({
                        { "<leader>ct", group = "toggle", mode = "n" },
                    })
                end
            end,
            keys = function()
                local keys = {
                    { "<leader>ctc", function() require("config.user_commands.toggle").common.toggle_cursor_center() end,     desc = "Toggle cursor center",          mode = "n" },
                    { "<leader>ctC", function() require("config.user_commands.toggle").common.toggle_cursor_center(true) end, desc = "Toggle cursor center (buffer)", mode = "n" },
                }
                if environment.is_vscode then
                    keys = utils.table_concat(keys, {
                        { "<leader>ctf", function() require("config.user_commands.toggle").vscode.toggle_fileformat() end, desc = "Toggle fileformat", mode = "n" },
                        { "<leader>ctw", function() require("config.user_commands.toggle").vscode.toggle_wrap() end,       desc = "Toggle wrap",       mode = "n" },
                    })
                else
                    keys = utils.table_concat(keys, {
                        { "<leader>ctf", function() require("config.user_commands.toggle").nvim.toggle_fileformat() end, desc = "Toggle fileformat", mode = "n" },
                        { "<leader>cts", function() require("config.user_commands.toggle").nvim.toggle_spell() end,      desc = "Toggle spell",      mode = "n" },
                        { "<leader>ctS", function() require("config.user_commands.toggle").nvim.toggle_syntax() end,     desc = "Toggle syntax",     mode = "n" },
                        { "<leader>ctw", function() require("config.user_commands.toggle").nvim.toggle_wrap() end,       desc = "Toggle wrap",       mode = "n" },
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
            config = function(_, opts)
                require("config.user_commands.undoquit").setup(opts)
            end,
            dir = path.config_path .. "/lua/config/user_commands/undoquit",
            enabled = not environment.is_vscode,
            event = {
                "QuitPre",
            },
            keys = {
                { keymap["<c-s-t>"],               function() require("config.user_commands.undoquit").restore_window() end, desc = "Undo quit",     mode = "n" },
                { "<leader>" .. keymap["<c-s-t>"], function() require("config.user_commands.undoquit").restore_tab() end,    desc = "Undo quit tab", mode = "n" },
            },
            name = "config.user_commands.undoquit",
            opts = {},
        },
    },
    defaults = {
        -- Set this to `true` to have all your plugins lazy-loaded by default.
        -- Only do this if you know what you are doing, as it can lead to unexpected behavior.
        lazy = true, -- should plugins be lazy-loaded?
    },
    -- lockfile generated after running update.
    lockfile = path.data_path .. "/lazy/lazy-lock.json",
    install = {
        -- try to load one of these colorschemes when starting an installation during startup
        colorscheme = { "onedark" },
    },
    ui = {
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "rounded",
        -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
        backdrop = 100,
    },
    checker = {
        -- automatically check for plugin updates
        enabled = not environment.is_vscode,
    },
    change_detection = {
        -- get a notification when changes are found
        notify = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
                "man",
                "osc52", -- Wezterm doesn't support osc52 yet
                "spellfile",
            },
        },
    },
})
