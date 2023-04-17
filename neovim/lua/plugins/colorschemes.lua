local variables = require("variables")

return {
    {
        "olimorris/onedarkpro.nvim",
        cond = not variables.is_vscode,
        config = function(_, opts)
            require("onedarkpro").setup(opts)

            vim.cmd.colorscheme("onedark")
        end,
        opts = {
            options = {
                transparency = true,
            }
        },
        priority = 1000,
    },
}
