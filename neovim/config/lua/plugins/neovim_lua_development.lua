local environment = require("utils.environment")

return {
    {
        "folke/lazydev.nvim",
        cmd = {
            "LazyDev",
        },
        cond = not environment.is_vscode and environment.lsp_enable,
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
