return {
    {
        "chrisgrieser/nvim-spider",
        keys = {
            { "w",  function() require("spider").motion("w") end,  desc = "Next word",            mode = { "n", "x" } },
            { "e",  function() require("spider").motion("e") end,  desc = "Next end of word",     mode = { "n", "x" } },
            { "b",  function() require("spider").motion("b") end,  desc = "Previous word",        mode = { "n", "x" } },
            { "ge", function() require("spider").motion("ge") end, desc = "Previous end of word", mode = { "n", "x" } },
        },
        opts = {
            skipInsignificantPunctuation = true,
        },
    },

    {
        "folke/flash.nvim",
        keys = {
            { "m", function() require("flash").jump() end, desc = "Flash",     mode = { "n", "x" } },
            { "/", desc = "Search forward",                mode = { "n", "x" } },
            { "?", desc = "Search backward",               mode = { "n", "x" } },
            { "f", desc = "Move to next char",             mode = { "n", "x" } },
            { "F", desc = "Move to previous char",         mode = { "n", "x" } },
            { "t", desc = "Move before next char",         mode = { "n", "x" } },
            { "T", desc = "Move before next char",         mode = { "n", "x" } },
        },
        opts = {
            search = {
                multi_window = false,
            },
            label = {
                uppercase = false,
                after = false,
                before = true,
            },
            modes = {
                char = {
                    config = function(opts)
                        if vim.fn.mode(true):find("o") then
                            local autohide_operator_list = { "y", "d", "g@" }
                            for _, operator in ipairs(autohide_operator_list) do
                                if vim.v.operator == operator then
                                    opts.autohide = true
                                    break
                                end
                            end
                        else
                            if vim.v.count == 0 then
                                opts.jump_labels = true
                            else
                                opts.autohide = true
                            end
                        end
                    end,
                    highlight = {
                        backdrop = false,
                    },
                },
            },
        },
    },
}
