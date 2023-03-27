vim.keymap.set({"n", "x"}, "y", "<Plug>(YankyYank)", { silent = true })
vim.keymap.set({"n", "x"}, "p", "<Plug>(YankyPutAfter)", { silent = true })
vim.keymap.set({"n", "x"}, "P", "<Plug>(YankyPutBefore)", { silent = true })
-- vim.keymap.set({"n", "x"}, "gp", "<Plug>(YankyGPutAfter)", { silent = true })
-- vim.keymap.set({"n", "x"}, "gP", "<Plug>(YankyGPutBefore)", { silent = true })

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
