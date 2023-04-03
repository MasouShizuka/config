vim.api.nvim_set_hl(0, "EyelinerPrimary", { fg = "#ff007c", bold = true, ctermfg = 198, cterm = { bold = true } })
vim.api.nvim_set_hl(0, "EyelinerSecondary", { fg = "#00dfff", bold = true, ctermfg = 45, cterm = { bold = true } })
vim.api.nvim_set_hl(0, "EyelinerDimmed", { fg = "#666666", sp = "#666666", ctermfg = 242 })

require("eyeliner").setup(
    {
        highlight_on_key = true, -- show highlights only after keypress
        dim = true               -- dim all other characters if set to true (recommended!)
    }
)
