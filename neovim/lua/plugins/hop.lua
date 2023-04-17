return {
    "phaazon/hop.nvim",
    branch = "v2",
    keys = {
        { "m", function() require("hop").hint_char1() end, mode = { "n", "x" } },
    },
    opts = {
        -- keys = "asdghklqwertyuiopzxcvbnmfj"
        keys = "qwertyuioplkjhgfdsazxcvbnm",
    }
}
