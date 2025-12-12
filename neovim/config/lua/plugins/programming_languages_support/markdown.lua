local environment = require("utils.environment")

return {
    {
        "HakonHarnes/img-clip.nvim",
        cmd = {
            "PasteImage",
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
        cond = not environment.is_vscode,
        event = {
            "User MarkdownFile",
        },
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        cmd = {
            "RenderMarkdown",
        },
        cond = not environment.is_vscode and environment.treesitter_enable,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-treesitter/nvim-treesitter",
        },
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
                overrides.buftype[bt] = {
                    enabled = false,
                }
            end

            return {
                latex = {
                    -- Turn on / off latex rendering.
                    enabled = false,
                },
                completions = {
                    -- Settings for in-process language server completions
                    lsp = { enabled = true },
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
                --   enabled, render_modes, debounce, anti_conceal, bullet, callout, checkbox, code, dash,
                --   document, heading, html, indent, inline_highlight, latex, link, padding, paragraph,
                --   pipe_table, quote, sign, win_options, yaml
                overrides = overrides,
            }
        end,
    },

    {
        "yousefhadder/markdown-plus.nvim",
        init = function()
            require("utils").create_once_autocmd("User", {
                callback = function()
                    vim.api.nvim_create_autocmd("FileType", {
                        callback = function(args)
                            if require("utils").is_available("which-key.nvim") then
                                require("which-key").add({
                                    { "sm",  buffer = args.buf, group = "markdown",          mode = { "n", "x" } },
                                    { "smf", buffer = args.buf, group = "markdown footnote", mode = "n" },
                                    { "smt", buffer = args.buf, group = "markdown table",    mode = { "n", "x" } },
                                })
                            end

                            local function map(mode, lhs, rhs, desc)
                                vim.keymap.set(mode, lhs, function()
                                    if not package.loaded["markdown-plus"] then
                                        require("lazy").load({ plugins = "markdown-plus.nvim" })
                                    end
                                    return rhs
                                end, { buffer = args.buf, desc = desc, expr = true, silent = true })
                            end

                            -- Text Formatting
                            map({ "n", "x" }, "smb", "<Plug>(MarkdownPlusBold)", "Toggle bold formatting")
                            map({ "n", "x" }, "smi", "<Plug>(MarkdownPlusItalic)", "Toggle bold formatting")
                            map({ "n", "x" }, "sms", "<Plug>(MarkdownPlusStrikethrough)", "Toggle strikethrough formatting")
                            map({ "n", "x" }, "smc", "<Plug>(MarkdownPlusCode)", "Toggle inline code formatting")
                            map({ "n", "x" }, "smh", "<Plug>(MarkdownPlusHighlight)", "Toggle highlight formatting")
                            map({ "n", "x" }, "smu", "<Plug>(MarkdownPlusUnderline)", "Toggle underline formatting")
                            map("x", "smC", "<Plug>(MarkdownPlusCodeBlock)", "Convert selection to code block")
                            map({ "n", "x" }, "smx", "<Plug>(MarkdownPlusClearFormatting)", "Clear all formatting")

                            -- Headers & TOC
                            map("n", "smtc", "<Plug>(MarkdownPlusGenerateTOC)", "Generate table of contents")
                            map("n", "smtu", "<Plug>(MarkdownPlusUpdateTOC)", "Update table of contents")

                            -- Links
                            map("n", "sml", "<Plug>(MarkdownPlusInsertLink)", "Insert markdown link")
                            map("x", "sml", "<Plug>(MarkdownPlusSelectionToLink)", "Convert selection to link")
                            map("n", "smU", "<Plug>(MarkdownPlusAutoLinkURL)", "Convert URL to markdown link")

                            -- Images
                            map("n", "smp", "<Plug>(MarkdownPlusInsertImage)", "Insert markdown image")
                            map("x", "smp", "<Plug>(MarkdownPlusSelectionToImage)", "Convert selection to image")

                            -- List Management
                            map("i", "<cr>", "<Plug>(MarkdownPlusListEnter)", "Auto-continue list or split content")
                            map("i", "<tab>", "<Plug>(MarkdownPlusListIndent)", "Indent list item")
                            map("i", "<s-tab>", "<Plug>(MarkdownPlusListOutdent)", "Outdent list item")
                            map("i", "<bs>", "<Plug>(MarkdownPlusListBackspace)", "Smart backspace (remove empty list)")
                            map("n", "o", "<Plug>(MarkdownPlusNewListItemBelow)", "New list item below")
                            map("n", "O", "<Plug>(MarkdownPlusNewListItemAbove)", "New list item above")
                            map({ "n", "x" }, "<cr>", "<Plug>(MarkdownPlusToggleCheckbox)", "Toggle checkbox")

                            -- Quotes
                            map({ "n", "x" }, "smq", "<Plug>(MarkdownPlusToggleQuote)", "Toggle blockquote")

                            -- Callouts
                            map({ "n", "x" }, "smQ", "<Plug>(MarkdownPlusInsertCallout)", "Insert/wrap callout")

                            -- Footnotes
                            map("n", "smff", "<Plug>(MarkdownPlusFootnoteInsert)", "Insert footnote")
                            map("n", "smfd", "<Plug>(MarkdownPlusFootnoteDelete)", "Delete footnote")

                            -- Tables
                            map("n", "smtt", "<Plug>(markdown-plus-table-create)", "Create new table")
                            map("n", "smtf", "<Plug>(markdown-plus-table-format)", "Format table")
                            map("n", "<s-down>", "<Plug>(markdown-plus-table-insert-row-below)", "Insert row below")
                            map("n", "<s-up>", "<Plug>(markdown-plus-table-insert-row-above)", "Insert row above")
                            map("n", "dr", "<Plug>(markdown-plus-table-delete-row)", "Delete row")
                            map("n", "yr", "<Plug>(markdown-plus-table-duplicate-row)", "Duplicate row")
                            map("n", "<s-right>", "<Plug>(markdown-plus-table-insert-column-right)", "Insert column right")
                            map("n", "<s-left>", "<Plug>(markdown-plus-table-insert-column-left)", "Insert column left")
                            map("n", "dc", "<Plug>(markdown-plus-table-delete-column)", "Delete column")
                            map("n", "yc", "<Plug>(markdown-plus-table-duplicate-column)", "Duplicate column")
                            map("n", "smta", "<Plug>(markdown-plus-table-toggle-cell-alignment)", "Toggle cell alignment")
                            map("n", "dC", "<Plug>(markdown-plus-table-clear-cell)", "Clear cell content")
                            map("n", "<c-up>", "<Plug>(markdown-plus-table-move-row-up)", "Move row up")
                            map("n", "<c-down>", "<Plug>(markdown-plus-table-move-row-down)", "Move row down")
                            map("n", "<c-left>", "<Plug>(markdown-plus-table-move-column-left)", "Move column left")
                            map("n", "<c-right>", "<Plug>(markdown-plus-table-move-column-right)", "Move column right")
                            map("n", "smtT", "<Plug>(markdown-plus-table-transpose)", "Transpose table")
                            map("n", "smts", "<Plug>(markdown-plus-table-sort-ascending)", "Sort table by column (ascending)")
                            map("n", "smtS", "<Plug>(markdown-plus-table-sort-descending)", "Sort table by column (descending)")
                            map("n", "smtv", "<Plug>(markdown-plus-table-to-csv)", "Convert table to CSV")
                            map("n", "smtV", "<Plug>(markdown-plus-table-from-csv)", "Convert CSV to table")
                            map("n", "<left>", "<Plug>(markdown-plus-table-nav-left)", "Navigate to cell left or move cursor left")
                            map("n", "<right>", "<Plug>(markdown-plus-table-nav-right)", "Navigate to cell right or move cursor right")
                            map("n", "<up>", "<Plug>(markdown-plus-table-nav-up)", "Navigate to cell above or move cursor up")
                            map("n", "<down>", "<Plug>(markdown-plus-table-nav-down)", "Navigate to cell below or move cursor down")
                        end,
                        desc = "markdown-plus keymap",
                        group = vim.api.nvim_create_augroup("MarkdownPlusKeymap", { clear = true }),
                        pattern = "markdown",
                    })
                end,
                desc = "markdown-plus init",
                pattern = "IceLoad",
            })
        end,
        opts = {
            -- Table configuration
            table = {
                keymaps = {                         -- Table-specific keymaps (prefix based)
                    enabled = false,                -- default: true  provide table keymaps
                    insert_mode_navigation = false, -- default: true  Alt+hjkl cell navigation
                },
            },

            -- Global keymap configuration
            keymaps = {
                enabled = false, -- default: true  set false to disable ALL default maps (use <Plug>)
            },
        },
    },
}
