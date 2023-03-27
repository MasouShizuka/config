vim.keymap.set("", "m", function()
    require("hop").hint_char1()
end, { silent = true })

require("hop").setup(
    {
        -- keys = "asdghklqwertyuiopzxcvbnmfj"
        keys = "qwertyuioplkjhgfdsazxcvbnm",
    }
)
