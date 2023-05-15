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
        "phaazon/hop.nvim",
        branch = "v2",
        keys = {
            { "m", function() require("hop").hint_char1() end, desc = "Hop", mode = { "n", "x" } },
        },
        opts = {
            -- keys = "asdghklqwertyuiopzxcvbnmfj"
            keys = "asdfqwerzxcvjklmiuopghtybn",
        },
    },
}
