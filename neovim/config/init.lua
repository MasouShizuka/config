local environment = require("utils.environment")
local path = require("utils.path")

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

if not environment.is_vscode then
    vim.keymap.set("n", "<leader>z", function() require("lazy").home() end, { desc = "Lazy", silent = true })
end

-- https://shaobin-jiang.github.io/blog/posts/neovim-startup/
vim.api.nvim_create_autocmd("User", {
    callback = function()
        local function _trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "IceLoad" })
        end

        if vim.bo.filetype == "snacks_dashboard" then
            vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
                callback = function()
                    _trigger()
                    vim.api.nvim_del_augroup_by_name("IceLoadBuf")
                end,
                group = vim.api.nvim_create_augroup("IceLoadBuf", { clear = true }),
            })
        else
            _trigger()
        end

        vim.api.nvim_del_augroup_by_name("IceLoad")
    end,
    desc = "Trigger event after VeryLazy or BufRead",
    group = vim.api.nvim_create_augroup("IceLoad", { clear = true }),
    pattern = "VeryLazy",
})

-- Setup lazy.nvim
return require("lazy").setup({
    spec = {
        -- import your plugins
        { import = "config" },
        { import = "plugins" },
        { import = "plugins.programming_languages_support" },
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
        colorscheme = { "tokyonight" },
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
        notify = false, -- get a notification when changes are found
    },
    performance = {
        rtp = {
            ---@type string[] list any plugins you want to disable here
            disabled_plugins = {
                "editorconfig",
                "gzip",
                "man",
                -- "matchit",
                "matchparen",
                "netrwPlugin",
                "osc52",
                "rplugin",
                "shada",
                "spellfile",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
