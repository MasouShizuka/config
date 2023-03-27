vim.keymap.set("n", "dd", "dd", { silent = true })
vim.keymap.set("n", "X", "d", { silent = true })
vim.keymap.set("n", "XX", "dd", { silent = true })

require("cutlass").setup(
    {
        cut_key = nil,
        override_del = nil,
        -- exclude = {},
        exclude = {"nx", "xx", "nX", "xX"},
        registers = {
            select = "_",
            delete = "_",
            change = "_",
        },
    }
)
