local autocmd = vim.api.nvim_create_autocmd
local my_group = vim.api.nvim_create_augroup("my_group", {
    clear = true,
})

-- 用o换行不要延续注释
autocmd("BufEnter", {
    group = my_group,
    pattern = "*",
    callback = function()
        vim.opt.formatoptions = vim.opt.formatoptions
            - "c" -- don't auto-wrap comments using 'textwidth'
            + "r" -- do continue when pressing enter
            - "o" -- O and o, don't continue comments
    end,
})

-- Highlight on yank
-- autocmd("TextYankPost", {
--     group = my_group,
--     pattern = "*",
--     callback = function()
--         vim.highlight.on_yank({ timeout = 500 })
--     end,
-- })
