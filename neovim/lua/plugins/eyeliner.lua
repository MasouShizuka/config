return {
    "jinh0/eyeliner.nvim",
    config = function(_, opts)
        require("eyeliner").setup(opts)

        vim.api.nvim_set_hl(0, "EyelinerPrimary",
            { fg = "#ff007c", bold = true, ctermfg = 198, cterm = { bold = true } })
        vim.api.nvim_set_hl(0, "EyelinerSecondary",
            { fg = "#00dfff", bold = true, ctermfg = 45, cterm = { bold = true } })
        vim.api.nvim_set_hl(0, "EyelinerDimmed",
            { fg = "#666666", sp = "#666666", ctermfg = 242 })
    end,
    keys = {
        { "f", mode = { "n", "x", "o" } },
        { "F", mode = { "n", "x", "o" } },
        { "t", mode = { "n", "x", "o" } },
        { "T", mode = { "n", "x", "o" } },
    },
    opts = {
        highlight_on_key = true, -- show highlights only after keypress
        dim = true               -- dim all other characters if set to true (recommended!)
    },
}
