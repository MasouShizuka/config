local variables = require("variables")

return {
    "RRethy/vim-illuminate",
    cond = not variables.is_vscode,
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        { "<F7>",   function() require("illuminate").goto_next_reference(false) end, mode = "n" },
        { "<S-F7>", function() require("illuminate").goto_prev_reference(false) end, mode = "n" },
    },
}
