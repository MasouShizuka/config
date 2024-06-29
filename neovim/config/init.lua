local environment = require("utils.environment")
local path = require("utils.path")

-- Bootstrap lazy.nvim
local lazypath = path.data_path .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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
            config = true,
            dir = path.config_path .. "/lua/config/options",
            event = {
                "VimEnter",
            },
            name = "config.options",
            priority = 10000,
        },
        {
            config = true,
            dir = path.config_path .. "/lua/config/mappings",
            event = {
                "VeryLazy",
            },
            name = "config.mappings",
        },
        {
            config = true,
            dir = path.config_path .. "/lua/config/autocommands",
            lazy = false,
            name = "config.autocommands",
        },
        {
            config = true,
            dir = path.config_path .. "/lua/config/user_commands",
            event = {
                "VeryLazy",
            },
            name = "config.user_commands",
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
