local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        "chrisgrieser/nvim-scissors",
        cmd = {
            "ScissorsAddNewSnippet",
            "ScissorsEditSnippet",
        },
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        enabled = not environment.is_vscode,
        keys = {
            { "<leader>Sa", function() require("scissors").addNewSnippet() end, desc = "Scissors add new snippet", mode = { "n", "x" } },
            { "<leader>Se", function() require("scissors").editSnippet() end,   desc = "Scissors edit snippet",    mode = "n" },
        },
        opts = {
            snippetDir = path.vscode_snippet_path,
            editSnippetPopup = {
                keymaps = {
                    cancel = "q",
                    saveChanges = "<cr>", -- alternatively, can also use `:w`
                    goBackToSearch = "<bs>",
                    deleteSnippet = "<c-bs>",
                    duplicateSnippet = "<c-d>",
                    openInFile = "<c-o>",
                    insertNextPlaceholder = "<c-p>", -- insert & normal mode
                },
            },
            -- `none` writes as a minified json file using `vim.encode.json`.
            -- `yq`/`jq` ensure formatted & sorted json files, which is relevant when
            -- you version control your snippets. To use a custom formatter, set to a
            -- list of strings, which will then be passed to `vim.system()`.
            jsonFormatter = { "jq", "--sort-keys", "--monochrome-output", "--indent", 4, "-b" }, -- "yq"|"jq"|"none"|table
        },
    },
}