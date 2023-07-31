return {
    {
        "kevinhwang91/nvim-hlslens",
        config = function(_, opts)
            local ok, _ = pcall(require, "scrollbar")
            if ok then
                require("scrollbar.handlers.search").setup(opts)
            else
                require("hlslens").setup(opts)
            end
        end,
        keys = {
            { "/", desc = "Search forward",  mode = { "n", "x" } },
            { "?", desc = "Search backward", mode = { "n", "x" } },
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
