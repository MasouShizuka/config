local variables = require("variables")

return {
    "AndrewRadev/undoquit.vim",
    cond = not variables.is_vscode,
    event = { "BufEnter" },
    init = function()
        vim.g.undoquit_mapping = "<C-T>"
        vim.g.undoquit_tab_mapping = "<Leader><C-T>"
    end,
    keys = {
        { "<C-T>",         mode = "n" },
        { "<Leader><C-T>", mode = "n" },
    },
}
