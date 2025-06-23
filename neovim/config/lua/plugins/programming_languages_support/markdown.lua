local environment = require("utils.environment")

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
                -- file and directory options
                ---@type string | fun(): string
                dir_path = function() -- directory path to save images to, can be relative (cwd or current file) or absolute
                    return "_images_" .. vim.fn.expand("%:t:r")
                end,
                file_name = "%Y-%m-%d-%H-%M-%S", ---@type string | fun(): string
                relative_to_current_file = true, ---@type boolean | fun(): boolean

                -- prompt options
                prompt_for_file_name = false, ---@type boolean | fun(): boolean
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
                    vim.keymap.set({ "n", "x" }, "<enter>", function() vim.api.nvim_command("MkdnToggleToDo") end, { buffer = args.buf, desc = "Toggle todo" })
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
                foldtext = false,
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
        "MeanderingProgrammer/render-markdown.nvim",
        cmd = {
            "RenderMarkdown",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not environment.is_vscode and environment.treesitter_enable,
        event = {
            "User MarkdownFile",
        },
        opts = function()
            local icons = require("utils.icons")
            local utils = require("utils")

            -- https://github.com/OXY2DEV/markview.nvim
            utils.set_hl(0, "RenderMarkdownH1Bg", { bg = "#453244", fg = "#f38ba8" })
            utils.set_hl(0, "RenderMarkdownH2Bg", { bg = "#46393e", fg = "#fab387" })
            utils.set_hl(0, "RenderMarkdownH3Bg", { bg = "#464245", fg = "#f9e2af" })
            utils.set_hl(0, "RenderMarkdownH4Bg", { bg = "#374243", fg = "#a6e3a1" })
            utils.set_hl(0, "RenderMarkdownH5Bg", { bg = "#2e3d51", fg = "#74c7ec" })
            utils.set_hl(0, "RenderMarkdownH6Bg", { bg = "#393b54", fg = "#b4befe" })

            utils.set_hl(0, "RenderMarkdownH1", { fg = "#f38ba8" })
            utils.set_hl(0, "RenderMarkdownH2", { fg = "#fab387" })
            utils.set_hl(0, "RenderMarkdownH3", { fg = "#f9e2af" })
            utils.set_hl(0, "RenderMarkdownH4", { fg = "#a6e3a1" })
            utils.set_hl(0, "RenderMarkdownH5", { fg = "#74c7ec" })
            utils.set_hl(0, "RenderMarkdownH6", { fg = "#b4befe" })

            local overrides = {
                -- Override for different buftype values, @see :h 'buftype'.
                buftype = {},
            }
            for _, bt in ipairs(require("utils.buftype").skip_buftype_list) do
                overrides.buftype[bt] = {}
                overrides.buftype[bt].enabled = false
            end

            return {
                latex = {
                    -- Turn on / off latex rendering.
                    enabled = false,
                },
                heading = {
                    -- Replaces '#+' of 'atx_h._marker'.
                    -- Output is evaluated depending on the type.
                    -- | function | `value(context)`              |
                    -- | string[] | `cycle(value, context.level)` |
                    icons = {
                        icons.misc.format_header_1,
                        icons.misc.format_header_2,
                        icons.misc.format_header_3,
                        icons.misc.format_header_4,
                        icons.misc.format_header_5,
                        icons.misc.format_header_6,
                    },
                },
                code = {
                    -- Width of the code block background.
                    -- | block | width of the code block  |
                    -- | full  | full width of the window |
                    width = "block",
                    -- Determines how the top / bottom of code block are rendered.
                    -- | none  | do not render a border                               |
                    -- | thick | use the same highlight as the code body              |
                    -- | thin  | when lines are empty overlay the above & below icons |
                    -- | hide  | conceal lines unless language name or icon is added  |
                    border = "thin",
                },
                pipe_table = {
                    -- Pre configured settings largely for setting table border easier.
                    -- | heavy  | use thicker border characters     |
                    -- | double | use double line border characters |
                    -- | round  | use round border corners          |
                    -- | none   | does nothing                      |
                    preset = "round",
                },
                html = {
                    comment = {
                        -- Turn on / off HTML comment concealing.
                        conceal = false,
                    },
                },
                -- More granular configuration mechanism, allows different aspects of buffers to have their own
                -- behavior. Values default to the top level configuration if no override is provided. Supports
                -- the following fields:
                --   enabled, max_file_size, debounce, render_modes, anti_conceal, padding, heading, paragraph,
                --   code, dash, bullet, checkbox, quote, pipe_table, callout, link, sign, indent, latex, html,
                --   win_options
                overrides = overrides,
            }
        end,
    },
}
