vim.api.nvim_set_keymap("n", "y", "<Plug>(YankyYank)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "y", "<Plug>(YankyYank)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "p", "<Plug>(YankyPutAfter)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "p", "<Plug>(YankyPutAfter)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "P", "<Plug>(YankyPutBefore)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "P", "<Plug>(YankyPutBefore)", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "gp", "<Plug>(YankyGPutAfter)", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "gp", "<Plug>(YankyGPutAfter)", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "gP", "<Plug>(YankyGPutBefore)", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "gP", "<Plug>(YankyGPutBefore)", { noremap = true, silent = true })

require("yanky").setup(
    {
        ring = {
            -- history_length = 100,
            history_length = 0,
            -- storage = "shada",
            storage = "memory",
            sync_with_numbered_registers = true,
            cancel_event = "update",
        },
        picker = {
            select = {
                action = nil, -- nil to use default put action
            },
            telescope = {
                mappings = nil, -- nil to use default mappings
            },
        },
        system_clipboard = {
            sync_with_ring = true,
        },
        highlight = {
            on_put = true,
            on_yank = true,
            timer = 500,
        },
        preserve_cursor_position = {
            enabled = true,
        },
    }
)
