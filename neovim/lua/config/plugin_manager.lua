local environment = require("utils.environment")
local path = require("utils.path")

local lazypath = path.data_path .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>z", function() require("lazy").home() end, { desc = "Lazy", silent = true })

return require("lazy").setup(
    {
        { import = "plugins" },
        {
            config = true,
            dir = path.config_path,
            main = "config.options",
            name = "config.options",
            priority = 10000,
            event = {
                "VimEnter",
            },
        },
        {
            config = true,
            dir = path.config_path,
            main = "config.mappings",
            name = "config.mappings",
            priority = 10000,
            event = {
                "VimEnter",
            },
        },
        {
            config = true,
            dir = path.config_path,
            lazy = false,
            main = "config.autocommands",
            name = "config.autocommands",
        },
        {
            config = true,
            dir = path.config_path,
            main = "config.user_commands",
            name = "config.user_commands",
            event = {
                "VeryLazy",
            },
        },
    },
    {
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
                },
            },
        },
    })
