local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

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
        init = function()
            if utils.is_available("which-key.nvim") then
                require("which-key").add({
                    { "<leader>S", group = "scissors", mode = "n" },
                })
            end
        end,
        keys = {
            { "<leader>Sa", function() require("scissors").addNewSnippet() end, desc = "Snippet: Add",  mode = { "n", "x" } },
            { "<leader>Se", function() require("scissors").editSnippet() end,   desc = "Snippet: Edit", mode = "n" },
        },
        opts = {
            snippetDir = path.vscode_snippet_path,
            editSnippetPopup = {
                keymaps = {
                    -- if not mentioned otherwise, the keymaps apply to normal mode
                    -- cancel = "q",
                    -- saveChanges = "<cr>", -- alternatively, can also use `:w`
                    -- goBackToSearch = "<bs>",
                    -- deleteSnippet = "<c-bs>",
                    -- duplicateSnippet = "<c-d>",
                    -- openInFile = "<c-o>",
                    -- insertNextPlaceholder = "<c-p>", -- insert & normal mode
                    -- showHelp = "?",
                },
            },
            -- `none` writes as a minified json file using `vim.encode.json`.
            -- `yq`/`jq` ensure formatted & sorted json files, which is relevant when
            -- you version control your snippets. To use a custom formatter, set to a
            -- list of strings, which will then be passed to `vim.system()`.
            ---@type "yq"|"jq"|"none"|string[]
            jsonFormatter = { "jq", "--sort-keys", "--monochrome-output", "--indent", 4, "-b" },
        },
    },
}
