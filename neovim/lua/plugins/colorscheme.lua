local variables = require("config.variables")

return {
    {
        "olimorris/onedarkpro.nvim",
        enabled = not variables.is_vscode,
        config = function(_, opts)
            require("onedarkpro").setup(opts)

            local colors = require("onedarkpro.helpers").get_preloaded_colors()
            for color, value in pairs(colors) do
                vim.api.nvim_set_hl(0, color, { fg = value })
            end

            vim.cmd.colorscheme("onedark")
        end,
        lazy = false,
        opts = {
            highlights = {
                MatchParen = {
                    bg = "${gray}"
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
