local environment = require("utils.environment")

return {
    {
        "folke/which-key.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        keys = {
            { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Local Keymaps (which-key)",  mode = "n" },
        },
        lazy = true,
        opts = {},
    },
}
