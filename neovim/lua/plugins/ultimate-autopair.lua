local variables = require("variables")

return {
    "altermo/ultimate-autopair.nvim",
    cond = not variables.is_vscode,
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {},
}
