local environment = require("utils.environment")
local path = require("utils.path")

local lazypath = path.data_path .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

if vim.g.mapleader == nil then
    vim.g.mapleader = " "
end
vim.keymap.set( "n", "<leader>z", function() require("lazy").home() end, { desc = "Lazy", silent = true })

return require("lazy").setup("plugins", {
    lockfile = path.data_path .. "/lazy/lazy-lock.json",
    install = {
        colorscheme = { "onedark" },
    },
    ui = {
        border = "rounded",
    },
    checker = {
        enabled = not environment.is_vscode,
    },
    change_detection = {
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
