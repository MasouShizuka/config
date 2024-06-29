local environment = require("utils.environment")

return {
    {
        "olimorris/onedarkpro.nvim",
        enabled = not environment.is_vscode,
        config = function(_, opts)
            require("onedarkpro").setup(opts)

            vim.cmd.colorscheme("onedark")
        end,
        lazy = false,
        opts = {
            highlights = {
                MatchParen = {
                    bg = "${gray}",
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
