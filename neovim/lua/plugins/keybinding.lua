local variables = require("config.variables")

return {
    {
        "folke/which-key.nvim",
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)

            wk.register({
                mode = "n",
                ["<leader>w"] = {
                    name = "+which-key",
                },
            })
        end,
        enabled = not variables.is_vscode,
        keys = {
            { "<leader>ww", function() require("which-key").show_command() end,        desc = "show all mappings",                 mode = "n" },
            { "<leader>wv", function() require("which-key").show_command("", "v") end, desc = "show all mappings for VISUAL mode", mode = "n" },
        },
        lazy = false,
        opts = {
            layout = {
                height = { min = 4, max = 25 },  -- min and max height of the columns
                width = { min = 20, max = 125 }, -- min and max width of the columns
                spacing = 3,                     -- spacing between columns
                align = "left",                  -- align columns left, center or right
            },
        },
    },
}
