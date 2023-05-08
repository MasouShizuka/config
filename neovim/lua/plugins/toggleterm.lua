local variables = require("variables")

return {
    "akinsho/toggleterm.nvim",
    cmd = {
        "ToggleTerm",
        "ToggleTermToggleAll",
        "TermExec",
        "ToggleTermSendCurrentLine",
        "ToggleTermSendVisualLines",
        "ToggleTermSendVisualSelection",
        "ToggleTermSetName",
    },
    cond = not variables.is_vscode,
    keys = {
        { variables.alacritty_keymap["<C-3>"], mode = { "n", "t" } },
    },
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return math.floor((vim.o.lines - vim.o.cmdheight) * 0.2)
            elseif term.direction == "vertical" then
                return math.floor(vim.o.columns * 0.2)
            end
        end,
        open_mapping = variables.alacritty_keymap["<C-3>"],
        persist_size = false,
        direction = "horizontal",
        shell = "pwsh -nologo",
        float_opts = {
            border = "curved",
            height = function()
                return math.floor((vim.o.lines - vim.o.cmdheight) * 0.8)
            end,
            width = function()
                return math.floor(vim.o.columns * 0.8)
            end,
        },
    },
    version = "*",
}
