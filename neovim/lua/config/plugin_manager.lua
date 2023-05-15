local variables = require("config.variables")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

local checker = true
if variables.is_vscode then
    checker = false
end

return require("lazy").setup("plugins", {
    change_detection = {
        notify = false,
    },
    checker = {
        enabled = checker,
    },
    install = {
        colorscheme = { "onedark" },
    },
    ui = {
        border = "rounded",
    },
})
