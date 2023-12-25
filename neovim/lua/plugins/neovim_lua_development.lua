local environment = require("utils.environment")

return {
    {
        "folke/neodev.nvim",
        enabled = not environment.is_vscode,
        lazy = true,
        opts = {
            library = {
                plugins = false,
            },
        },
    },
}
