vim.opt.list = true
vim.opt.listchars:append "tab:··,trail:·"

require("indent_blankline").setup(
    {
        show_end_of_line = true,
    }
)
