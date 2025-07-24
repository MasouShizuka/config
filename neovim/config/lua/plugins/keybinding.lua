local environment = require("utils.environment")

return {
    {
        "folke/which-key.nvim",
        config = function(_, opts)
            require("which-key").setup(opts)

            require("which-key").add({
                { "<leader>c", group = "user commands", mode = "n" },
                { "<leader>k", group = "keymap",        mode = "n" },
            })
        end,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        keys = {
            { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Local Keymaps (which-key)", mode = "n" },
        },
        lazy = true,
        opts = {
            -- Start hidden and wait for a key to be pressed before showing the popup
            -- Only used by enabled xo mapping modes.
            ---@param ctx { mode: string, operator: string }
            defer = function(ctx)
                return vim.list_contains({ "<C-V>", "V", "v" }, ctx.mode)
            end,
        },
    },
}
