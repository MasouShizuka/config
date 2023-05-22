local variables = require("config.variables")

return {
    {
        "olimorris/onedarkpro.nvim",
        enabled = not variables.is_vscode,
        config = function(_, opts)
            require("onedarkpro").setup(opts)

            vim.cmd.colorscheme("onedark")
        end,
        lazy = false,
        opts = {
            highlights = {
                BufferLineBufferSelected = {
                    fg = "#c678dd",
                    style = "bold",
                },
                BufferLineNumbersSelected = {
                    fg = "#c678dd",
                    style = "bold",
                },
            },
            options = {
                cursorline = true,
                transparency = true,
            },
        },
        priority = 1000,
    },
}
