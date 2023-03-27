local variables = require("variables")

if not variables.is_vscode then
    local colorscheme = "onedark"

    vim.cmd.colorscheme(colorscheme)
end
