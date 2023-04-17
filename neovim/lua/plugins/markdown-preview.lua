local variables = require("variables")

return {
    "iamcco/markdown-preview.nvim",
    build = function()
        vim.fn["mkdp#util#install"]()
    end,
    cond = not variables.is_vscode,
    ft = "markdown",
}
