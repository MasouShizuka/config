local environment = require("utils.environment")
local keymap = require("utils.keymap")

return {
    {
        "ekickx/clipboard-image.nvim",
        cmd = {
            "PasteImg",
        },
        enabled = not environment.is_vscode,
        keys = {
            { "<leader>p", function() vim.api.nvim_command("PasteImg") end, desc = "Paste image", mode = "n" },
        },
        opts = {
            default = {
                -- img_dir = "_images",
                img_dir = function()
                    return vim.fn.expand("%:.:h") .. "/_images_" .. vim.fn.expand("%:t:r")
                end,
                -- img_dir_txt = "_images",
                img_dir_txt = function()
                    return "_images_" .. vim.fn.expand("%:t:r")
                end,
                img_name = function()
                    return os.date("%Y-%m-%d-%H-%M-%S")
                end,
                img_handler = function(img) end,
                affix = "%s",
            },
            asciidoc = {
                affix = "image::%s[]",
            },
            markdown = {
                affix = "![](%s)",
            },
        },
    },

    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        cmd = {
            "MarkdownPreview",
            "MarkdownPreviewStop",
            "MarkdownPreviewToggle",
        },
        enabled = not environment.is_vscode,
        ft = "markdown",
    },

    {
        "jakewvincent/mkdnflow.nvim",
        enabled = not environment.is_vscode,
        ft = "markdown",
        -- keys = {
        --     { keymap["<c-space>"], function() vim.api.nvim_command("MkdnToggleToDo") end,             desc = "Toggle todo",                mode = { "n", "x" } },
        --     { "<cr>",              function() vim.api.nvim_command("MkdnNewListItem") end,            desc = "New list item",              mode = "i" },
        --     { "o",                 function() vim.api.nvim_command("MkdnNewListItemBelowInsert") end, desc = "New list item below insert", mode = "n" },
        --     { "O",                 function() vim.api.nvim_command("MkdnNewListItemAboveInsert") end, desc = "New list item above insert", mode = "n" },
        --     { "<tab>",             function() vim.api.nvim_command("MkdnTableNextCell") end,          desc = "Table next cell",            mode = { "n", "i" } },
        --     { "<s-tab>",           function() vim.api.nvim_command("MkdnTablePrevCell") end,          desc = "Table previous cell",        mode = { "n", "i" } },
        --     { "<s-down>",          function() vim.api.nvim_command("MkdnTableNewRowBelow") end,       desc = "Table new row below",        mode = { "n", "i" } },
        --     { "<s-up>",            function() vim.api.nvim_command("MkdnTableNewRowAbove") end,       desc = "Table new row above",        mode = { "n", "i" } },
        --     { "<s-right>",         function() vim.api.nvim_command("MkdnTableNewColAfter") end,       desc = "Table new column after",     mode = { "n", "i" } },
        --     { "<s-left>",          function() vim.api.nvim_command("MkdnTableNewColBefore") end,      desc = "Table new column before",    mode = { "n", "i" } },
        -- },
        opts = {
            modules = {
                bib = false,
                buffers = false,
                conceal = false,
                cursor = false,
                folds = false,
                links = false,
                lists = true,
                maps = true,
                paths = false,
                tables = true,
                yaml = false,
            },
            silent = true,
            to_do = {
                symbols = { " ", "-", "X" },
                update_parents = true,
                not_started = " ",
                in_progress = "-",
                complete = "X",
            },
            tables = {
                trim_whitespace = true,
                format_on_move = true,
                auto_extend_rows = false,
                auto_extend_cols = false,
            },
            mappings = {
                Mkdnflow = false,
                MkdnEnter = false,
                MkdnTab = { { "n", "i" }, "<tab>" },
                MkdnSTab = { { "n", "i" }, "<s-tab>" },
                MkdnGoBack = false,
                MkdnGoForward = false,
                MkdnMoveSource = false,
                MkdnNextLink = false,
                MkdnPrevLink = false,
                MkdnFollowLink = false,
                MkdnCreateLink = false,
                MkdnCreateLinkFromClipboard = false,
                MkdnDestroyLink = false,
                MkdnTagSpan = false,
                MkdnYankAnchorLink = false,
                MkdnYankFileAnchorLink = false,
                MkdnNextHeading = false,
                MkdnPrevHeading = false,
                MkdnIncreaseHeading = false,
                MkdnDecreaseHeading = false,
                MkdnToggleToDo = { { "n", "x" }, keymap["<c-space>"] },
                MkdnNewListItem = { "i", "<cr>" },
                MkdnNewListItemBelowInsert = { "n", "o" },
                MkdnNewListItemAboveInsert = { "n", "O" },
                MkdnExtendList = false,
                MkdnUpdateNumbering = false,
                MkdnTable = false,
                MkdnTableFormat = false,
                MkdnTableNextCell = false,
                MkdnTablePrevCell = false,
                MkdnTableNextRow = false,
                MkdnTablePrevRow = false,
                MkdnTableNewRowBelow = { { "n", "i" }, "<s-down>" },
                MkdnTableNewRowAbove = { { "n", "i" }, "<s-up>" },
                MkdnTableNewColAfter = { { "n", "i" }, "<s-right>" },
                MkdnTableNewColBefore = { { "n", "i" }, "<s-left>" },
                MkdnFoldSection = false,
                MkdnUnfoldSection = false,
            },
        },
    },
}
