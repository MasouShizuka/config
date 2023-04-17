local variables = require("variables")

return {
    "lukas-reineke/indent-blankline.nvim",
    cond = not variables.is_vscode,
    event = { "BufReadPost", "BufNewFile" },
}
