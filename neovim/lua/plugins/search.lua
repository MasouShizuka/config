return {
    {
        "kevinhwang91/nvim-hlslens",
        keys = {
            { "/", desc = "Search", mode = "n" },
            {
                "n",
                function()
                    vim.api.nvim_command("normal! " .. vim.api.nvim_get_vvar("count1") .. "n")
                    require("hlslens").start()
                    vim.cmd.normal("zz")
                end,
                desc = "Next",
                mode = "n",
            },
            {
                "N",
                function()
                    vim.api.nvim_command("normal! " .. vim.api.nvim_get_vvar("count1") .. "N")
                    require("hlslens").start()
                    vim.cmd.normal("zz")
                end,
                desc = "Previous",
                mode = "n",
            },
            {
                "*",
                function()
                    local keys = vim.api.nvim_replace_termcodes("*", true, false, true)
                    vim.api.nvim_feedkeys(keys, "n", false)
                    require("hlslens").start()
                    vim.cmd.normal("zz")
                end,
                desc = "Next",
                mode = "n",
            },
            {
                "#",
                function()
                    local keys = vim.api.nvim_replace_termcodes("#", true, false, true)
                    vim.api.nvim_feedkeys(keys, "n", false)
                    require("hlslens").start()
                    vim.cmd.normal("zz")
                end,
                desc = "Previous",
                mode = "n",
            },
            {
                "g*",
                function()
                    local keys = vim.api.nvim_replace_termcodes("g*", true, false, true)
                    vim.api.nvim_feedkeys(keys, "n", false)
                    require("hlslens").start()
                    vim.cmd.normal("zz")
                end,
                desc = "Next",
                mode = "n",
            },
            {
                "g#",
                function()
                    local keys = vim.api.nvim_replace_termcodes("g#", true, false, true)
                    vim.api.nvim_feedkeys(keys, "n", false)
                    require("hlslens").start()
                    vim.cmd.normal("zz")
                end,
                desc = "Previous",
                mode = "n",
            },
        },
        opts = {
            calm_down = true,
            nearest_only = true,
            nearest_float_when = "always",
        },
    },
}