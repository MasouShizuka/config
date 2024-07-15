local environment = require("utils.environment")

return {
    {
        "folke/lazydev.nvim",
        cmd = {
            "LazyDev",
        },
        enabled = not environment.is_vscode,
        lazy = true,
        opts = {},
    },
}
