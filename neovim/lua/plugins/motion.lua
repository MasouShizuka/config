return {
    {
        "chrisgrieser/nvim-spider",
        keys = {
            { "w", function() require("spider").motion("w") end, desc = "Next word",        mode = { "n", "x" } },
            { "e", function() require("spider").motion("e") end, desc = "Next end of word", mode = { "n", "x" } },
            { "b", function() require("spider").motion("b") end, desc = "Previous word",    mode = { "n", "x" } },
            -- { "ge", function() require("spider").motion("ge") end, desc = "Previous end of word", mode = { "n", "x" } },
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
                    autohide = vim.fn.mode(true):find("no") and (vim.v.operator == "y" or vim.v.operator == "d"),
                    keys = { "f", "F", "t", "T" },
                },
            },
        },
    },

    -- {
    --     "phaazon/hop.nvim",
    --     branch = "v2",
    --     keys = {
    --         { "m", function() require("hop").hint_char1() end, desc = "Hop", mode = { "n", "x" } },
    --     },
    --     opts = {
    --         -- keys = "asdghklqwertyuiopzxcvbnmfj"
    --         keys = "asdfqwerzxcvjklmiuopghtybn",
    --     },
    -- },
}
