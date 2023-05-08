local variables = require("variables")

return {
    {
        "rcarriga/nvim-notify",
        cond = not variables.is_vscode,
        config = function(_, opts)
            require("notify").setup(opts)

            vim.notify = require("notify")
        end,
        event = { "UIEnter" },
        opts = {
            timeout = 3000,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            max_height = function()
                return math.floor((vim.o.lines - vim.o.cmdheight) * 0.75)
            end,
            background_colour = "#000000",
        },
    },

    {
        "stevearc/dressing.nvim",
        cond = not variables.is_vscode,
        event = { "UIEnter" },
    },
}
