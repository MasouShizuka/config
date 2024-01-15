local environment = require("utils.environment")
local keymap = require("utils.keymap")

return {
    -- {
    --     "dfendr/clipboard-image.nvim",
    --     cmd = {
    --         "PasteImg",
    --     },
    --     enabled = not environment.is_vscode,
    --     keys = {
    --         { "<leader>p", function() vim.api.nvim_command("PasteImg") end, desc = "Paste image", mode = "n" },
    --     },
    --     opts = {
    --         default = {
    --             -- img_dir = function()
    --             --     return vim.fn.expand("%:.:h") .. "/_images_" .. vim.fn.expand("%:t:r")
    --             -- end,
    --             img_dir = "img",
    --             -- img_dir_txt = function()
    --             --     return "_images_" .. vim.fn.expand("%:t:r")
    --             -- end,
    --             img_dir_txt = function ()

    --             end,
    --             img_name = function()
    --                 return os.date("%Y-%m-%d-%H-%M-%S")
    --             end,
    --             img_handler = function(img) end,
    --             affix = "%s",
    --         },
    --         asciidoc = {
    --             affix = "image::%s[]",
    --         },
    --         markdown = {
    --             affix = "![](%s)",
    --         },
    --     },
    -- },

    {
        "HakonHarnes/img-clip.nvim",
        cmd = {
            "PasteImage",
        },
        keys = {
            { "<leader>p", function() vim.api.nvim_command("PasteImage") end, desc = "Paste clipboard image" },
        },
        opts = {
            default = {
                dir_path = function()
                    return "_images_" .. vim.fn.expand("%:t:r")
                end,
                file_name = "%Y-%m-%d-%H-%M-%S", -- file name format (see lua.org/pil/22.1.html)
                relative_to_current_file = true, -- make dir_path relative to current file rather than the cwd
                prompt_for_file_name = false,    -- ask user for file name before saving, leave empty to use default
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
        ft = {
            "markdown",
        },
    },

    {
        "jakewvincent/mkdnflow.nvim",
        config = function(_, opts)
            require("mkdnflow").setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    vim.keymap.set({ "n", "x" }, keymap["<c-space>"], function() vim.api.nvim_command("MkdnToggleToDo") end, { buffer = args.buf, desc = "Toggle todo" })
                    vim.keymap.set("i", "<cr>", function() vim.api.nvim_command("MkdnNewListItem") end, { buffer = args.buf, desc = "New list item" })
                    vim.keymap.set("n", "o", function() vim.api.nvim_command("MkdnNewListItemBelowInsert") end, { buffer = args.buf, desc = "New list item below insert" })
                    vim.keymap.set("n", "O", function() vim.api.nvim_command("MkdnNewListItemAboveInsert") end, { buffer = args.buf, desc = "New list item above insert" })
                    vim.keymap.set({ "n", "i" }, "<tab>", function() vim.api.nvim_command("MkdnTableNextCell") end, { buffer = args.buf, desc = "Table next cell" })
                    vim.keymap.set({ "n", "i" }, "<s-tab>", function() vim.api.nvim_command("MkdnTablePrevCell") end, { buffer = args.buf, desc = "Table previous cell" })
                    vim.keymap.set({ "n", "i" }, "<s-down>", function() vim.api.nvim_command("MkdnTableNewRowBelow") end, { buffer = args.buf, desc = "Table new row below" })
                    vim.keymap.set({ "n", "i" }, "<s-up>", function() vim.api.nvim_command("MkdnTableNewRowAbove") end, { buffer = args.buf, desc = "Table new row above" })
                    vim.keymap.set({ "n", "i" }, "<s-right>", function() vim.api.nvim_command("MkdnTableNewColAfter") end, { buffer = args.buf, desc = "Table new column after" })
                    vim.keymap.set({ "n", "i" }, "<s-left>", function() vim.api.nvim_command("MkdnTableNewColBefore") end, { buffer = args.buf, desc = "Table new column before" })
                end,
                desc = "mkdnflow keymap",
                group = vim.api.nvim_create_augroup("MkdnflowKeymap", { clear = true }),
                pattern = "markdown",
            })
        end,
        enabled = not environment.is_vscode,
        ft = {
            "markdown",
        },
        opts = {
            modules = {
                bib = false,
                buffers = false,
                conceal = false,
                cursor = false,
                folds = false,
                links = false,
                lists = true,
                maps = false,
                paths = false,
                tables = true,
                yaml = false,
                cmp = false,
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
                style = {
                    cell_padding = 1,
                    separator_padding = 1,
                    outer_pipes = true,
                    mimic_alignment = true,
                },
            },
        },
    },
}
