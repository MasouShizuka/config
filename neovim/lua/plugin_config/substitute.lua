vim.api.nvim_set_keymap("n", "gr",
    "<cmd>lua require('substitute').operator()<cr>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "grr",
    "<cmd>lua require('substitute').line()<cr>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("v", "gr",
    "<cmd>lua require('substitute').visual()<cr>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "cx",
    "<cmd>lua require('substitute.exchange').operator()<cr>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "cxx",
    "<cmd>lua require('substitute.exchange').line()<cr>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("x", "X",
    "<cmd>lua require('substitute.exchange').visual()<cr>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "cxc",
    "<cmd>lua require('substitute.exchange').cancel()<cr>",
    { noremap = true, silent = true }
)

require("substitute").setup()
