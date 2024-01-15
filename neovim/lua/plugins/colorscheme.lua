local environment = require("utils.environment")

return {
    {
        "olimorris/onedarkpro.nvim",
        enabled = not environment.is_vscode,
        config = function(_, opts)
            require("onedarkpro").setup(opts)

            vim.api.nvim_set_hl(0, "black", { link = "EndOfBuffer" })
            vim.api.nvim_set_hl(0, "blue", { link = "DiagnosticInfo" })
            vim.api.nvim_set_hl(0, "cyan", { link = "DiagnosticHint" })
            vim.api.nvim_set_hl(0, "gray", { link = "NonText" })
            vim.api.nvim_set_hl(0, "green", { link = "String" })
            vim.api.nvim_set_hl(0, "orange", { link = "Constant" })
            vim.api.nvim_set_hl(0, "purple", { link = "Statement" })
            vim.api.nvim_set_hl(0, "red", { link = "DiagnosticError" })
            vim.api.nvim_set_hl(0, "white", { link = "Conceal" })
            vim.api.nvim_set_hl(0, "yellow", { link = "DiagnosticWarn" })

            vim.api.nvim_set_hl(0, "git_add", { link = "diffAdded" })
            vim.api.nvim_set_hl(0, "git_change", { link = "diffChanged" })
            vim.api.nvim_set_hl(0, "git_delete", { link = "diffRemoved" })

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
