local environment = require("utils.environment")
local icons = require("utils.icons")
local keymap = require("utils.keymap")

return {
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
                dir_path = function() -- directory path to save images to, can be relative (cwd or current file) or absolute
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
        event = {
            "User MarkdownFile",
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
                    vim.keymap.set({ "n", "i" }, "<tab>", function() vim.api.nvim_command("MkdnTableNextCell") end, { buffer = args.buf, desc = "Table next cell" })
                    vim.keymap.set({ "n", "i" }, "<s-tab>", function() vim.api.nvim_command("MkdnTablePrevCell") end, { buffer = args.buf, desc = "Table previous cell" })
                    vim.keymap.set({ "n", "i" }, "<s-down>", function() vim.api.nvim_command("MkdnTableNewRowBelow") end, { buffer = args.buf, desc = "Table new row below" })
                    vim.keymap.set({ "n", "i" }, "<s-up>", function() vim.api.nvim_command("MkdnTableNewRowAbove") end, { buffer = args.buf, desc = "Table new row above" })
                    vim.keymap.set({ "n", "i" }, "<s-right>", function() vim.api.nvim_command("MkdnTableNewColAfter") end, { buffer = args.buf, desc = "Table new column after" })
                    vim.keymap.set({ "n", "i" }, "<s-left>", function() vim.api.nvim_command("MkdnTableNewColBefore") end, { buffer = args.buf, desc = "Table new column before" })
                end,
                desc = "Mkdnflow keymap",
                group = vim.api.nvim_create_augroup("MkdnflowKeymap", { clear = true }),
                pattern = "markdown",
            })
        end,
        enabled = not environment.is_vscode,
        event = {
            "User MarkdownFile",
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
        },
    },

    {
        "MeanderingProgrammer/markdown.nvim",
        cmd = {
            "RenderMarkdownToggle",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not environment.is_vscode,
        event = {
            "User MarkdownFile",
        },
        name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
        opts = function()
            -- https://github.com/OXY2DEV/markview.nvim
            vim.api.nvim_set_hl(0, "MarkdownHeading1", { bg = "#453244", fg = "#f38ba8" })
            vim.api.nvim_set_hl(0, "MarkdownHeading2", { bg = "#46393e", fg = "#fab387" })
            vim.api.nvim_set_hl(0, "MarkdownHeading3", { bg = "#464245", fg = "#f9e2af" })
            vim.api.nvim_set_hl(0, "MarkdownHeading4", { bg = "#374243", fg = "#a6e3a1" })
            vim.api.nvim_set_hl(0, "MarkdownHeading5", { bg = "#2e3d51", fg = "#74c7ec" })
            vim.api.nvim_set_hl(0, "MarkdownHeading6", { bg = "#393b54", fg = "#b4befe" })

            return {
                latex = {
                    -- Whether LaTeX should be rendered, mainly used for health check
                    enabled = false,
                },
                heading = {
                    -- Replaces '#+' of 'atx_h._marker'
                    -- The number of '#' in the heading determines the 'level'
                    -- The 'level' is used to index into the array using a cycle
                    -- The result is left padded with spaces to hide any additional '#'
                    icons = {
                        icons.misc.format_header_1,
                        icons.misc.format_header_2,
                        icons.misc.format_header_3,
                        icons.misc.format_header_4,
                        icons.misc.format_header_5,
                        icons.misc.format_header_6,
                    },
                    -- The 'level' is used to index into the array using a clamp
                    -- Highlight for the heading icon and extends through the entire line
                    backgrounds = {
                        "MarkdownHeading1",
                        "MarkdownHeading2",
                        "MarkdownHeading3",
                        "MarkdownHeading4",
                        "MarkdownHeading5",
                        "MarkdownHeading6",
                    },
                },
                pipe_table = {
                    -- Characters used to replace table boarder
                    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
                    -- stylua: ignore
                    border = {
                        "╭", "┬", "╮",
                        "├", "┼", "┤",
                        "╰", "┴", "╯",
                        "│", "─",
                    },
                },
            }
        end,
    },
}
