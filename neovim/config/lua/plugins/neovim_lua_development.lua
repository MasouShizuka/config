local environment = require("utils.environment")

return {
    {
        "folke/lazydev.nvim",
        cmd = {
            "LazyDev",
        },
        enabled = not environment.is_vscode,
        lazy = true,
        opts = {
            integrations = {
                -- add the cmp source for completion of:
                -- `require "modname"`
                -- `---@module "modname"`
                cmp = false,
            },
        },
    },
}