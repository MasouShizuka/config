vim.keymap.set({ "n", "x" }, "w", function() require("spider").motion("w") end, { silent = true })
vim.keymap.set({ "n", "x" }, "e", function() require("spider").motion("e") end, { silent = true })
vim.keymap.set({ "n", "x" }, "b", function() require("spider").motion("b") end, { silent = true })
vim.keymap.set({ "n", "x" }, "ge", function() require("spider").motion("ge") end, { silent = true })

require("spider").setup(
    {
        skipInsignificantPunctuation = true
    }
)
