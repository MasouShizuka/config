local environment = require("utils.environment")

return {
    {
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
        enabled = not environment.is_vscode,
        opts = {
            size = function(term)
                if term.direction == "horizontal" then
                    return math.floor((vim.o.lines - vim.o.cmdheight) * 0.3)
                elseif term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.3)
                end
            end,
            persist_size = false,
            direction = "horizontal",
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
    },
}
