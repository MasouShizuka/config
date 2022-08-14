local autocmd = vim.api.nvim_create_autocmd

local myAutoGroup = vim.api.nvim_create_augroup("myAutoGroup", {
    clear = true,
})

-- 用o换行不要延续注释
autocmd("BufEnter", {
    group = myAutoGroup,
    pattern = "*",
    callback = function()
        vim.opt.formatoptions = vim.opt.formatoptions
            - "c" -- don't auto-wrap comments using 'textwidth'
            + "r" -- do continue when pressing enter
            - "o" -- O and o, don't continue comments
    end,
})

-- Highlight on yank
autocmd("TextYankPost", {
    group = myAutoGroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ timeout = 500 })
    end,
})

-- 修改lua/plugins.lua 自动更新插件
autocmd("BufWritePost", {
    group = myAutoGroup,
    -- autocmd BufWritePost plugins.lua source <afile> | PackerSync
    callback = function()
        if vim.fn.expand("<afile>") == "lua/plugins.lua" then
            vim.api.nvim_command("source lua/plugins.lua")
            vim.api.nvim_command("PackerSync")
        end
    end,
})
