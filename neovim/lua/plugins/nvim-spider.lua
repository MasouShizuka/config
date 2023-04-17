return {
    "chrisgrieser/nvim-spider",
    keys = {
        { "w", function() require("spider").motion("w") end, mode = { "n", "x" } },
        { "e", function() require("spider").motion("e") end, mode = { "n", "x" } },
        { "b", function() require("spider").motion("b") end, mode = { "n", "x" } },
        -- { "ge", function() require("spider").motion("ge") end, mode = { "n", "x" } },
    },
    opts = {
        skipInsignificantPunctuation = true,
    }
}
