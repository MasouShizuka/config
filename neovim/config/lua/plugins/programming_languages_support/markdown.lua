local environment = require("utils.environment")

return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        cmd = {
            "RenderMarkdown",
        },
        cond = not environment.is_vscode and environment.treesitter_enable,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "romus204/tree-sitter-manager.nvim",
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
        "selimacerbas/markdown-preview.nvim",
        cmd = {
            "MarkdownPreview",
            "MarkdownPreviewRefresh",
            "MarkdownPreviewStop",
        },
        cond = not environment.is_vscode,
        dependencies = {
            "selimacerbas/live-server.nvim",
        },
        opts = {},
    },

    {
        "yousefhadder/markdown-plus.nvim",
        init = function()
            require("utils").create_once_autocmd("User", {
                callback = function()
                    vim.api.nvim_create_autocmd("FileType", {
                        callback = function(args)
                            local utils = require("utils")

                            if utils.is_available("which-key.nvim") then
                                require("which-key").add({
                                    { "sm",  buffer = args.buf, group = "markdown",          mode = { "n", "x" } },
                                    { "smf", buffer = args.buf, group = "markdown footnote", mode = "n" },
                                    { "smt", buffer = args.buf, group = "markdown table",    mode = { "n", "x" } },
                                })
                            end

                            local function map_with_plug(mode, lhs, rhs, desc)
                                vim.keymap.set(mode, lhs, function()
                                    if not package.loaded["markdown-plus"] then
                                        utils.load_plugin("markdown-plus.nvim")
                                    end
                                    return rhs
                                end, { buf = args.buf, desc = desc, expr = true, silent = true })
                            end

                            local function map_with_func(mode, lhs, rhs, desc)
                                vim.keymap.set(mode, lhs, function()
                                    if not package.loaded["markdown-plus"] then
                                        utils.load_plugin("markdown-plus.nvim")
                                    end
                                    rhs()
                                end, { buf = args.buf, desc = desc, silent = true })
                            end

                            -- Text Formatting
                            map_with_plug({ "n", "x" }, "smb", "<Plug>(MarkdownPlusBold)", "Toggle bold formatting")
                            map_with_plug({ "n", "x" }, "smi", "<Plug>(MarkdownPlusItalic)", "Toggle italic formatting")
                            map_with_plug({ "n", "x" }, "sms", "<Plug>(MarkdownPlusStrikethrough)", "Toggle strikethrough formatting")
                            map_with_plug({ "n", "x" }, "smc", "<Plug>(MarkdownPlusCode)", "Toggle inline code formatting")
                            map_with_plug({ "n", "x" }, "smh", "<Plug>(MarkdownPlusHighlight)", "Toggle highlight formatting")
                            map_with_plug({ "n", "x" }, "smu", "<Plug>(MarkdownPlusUnderline)", "Toggle underline formatting")
                            map_with_plug("x", "smC", "<Plug>(MarkdownPlusCodeBlock)", "Convert selection to code block")
                            map_with_plug({ "n", "x" }, "smx", "<Plug>(MarkdownPlusClearFormatting)", "Clear all formatting")

                            -- Headers & TOC
                            map_with_plug("n", "smtc", "<Plug>(MarkdownPlusGenerateTOC)", "Generate table of contents")
                            map_with_plug("n", "smtu", "<Plug>(MarkdownPlusUpdateTOC)", "Update table of contents")

                            -- Links
                            map_with_plug("n", "sml", "<Plug>(MarkdownPlusInsertLink)", "Insert markdown link")
                            map_with_plug("x", "sml", "<Plug>(MarkdownPlusSelectionToLink)", "Convert selection to link")
                            map_with_plug("n", "smU", "<Plug>(MarkdownPlusAutoLinkURL)", "Convert URL to markdown link")

                            -- Images
                            map_with_plug("n", "smp", "<Plug>(MarkdownPlusInsertImage)", "Insert markdown image")
                            map_with_plug("x", "smp", "<Plug>(MarkdownPlusSelectionToImage)", "Convert selection to image")

                            -- List Management
                            map_with_func("i", "<cr>", function()
                                local handlers = require("markdown-plus.list.handlers")
                                handlers.skip_in_codeblock(handlers.handle_enter, "<CR>")()
                            end, "Auto-continue list or split content")
                            map_with_func("i", "<tab>", function()
                                local handlers = require("markdown-plus.list.handlers")
                                handlers.skip_in_codeblock(handlers.handle_tab, "<Tab>")()
                            end, "Indent list item")
                            map_with_func("i", "<s-tab>", function()
                                local handlers = require("markdown-plus.list.handlers")
                                handlers.skip_in_codeblock(handlers.handle_shift_tab, "<S-Tab>")()
                            end, "Outdent list item")
                            map_with_func("i", "<bs>", function()
                                local handlers = require("markdown-plus.list.handlers")
                                handlers.skip_in_codeblock(handlers.handle_backspace, "<BS>")()
                            end, "Smart backspace (remove empty list)")
                            map_with_func("n", "o", function()
                                local handlers = require("markdown-plus.list.handlers")
                                handlers.skip_in_codeblock(handlers.handle_normal_o, "o")()
                            end, "New list item below")
                            map_with_func("n", "O", function()
                                local handlers = require("markdown-plus.list.handlers")
                                handlers.skip_in_codeblock(handlers.handle_normal_O, "O")()
                            end, "New list item above")
                            map_with_func({ "n", "x" }, "<cr>", function()
                                local checkbox = require("markdown-plus.list.checkbox")
                                checkbox.toggle_checkbox_line()
                                checkbox.toggle_checkbox_range()
                                checkbox.toggle_checkbox_insert()
                            end, "Toggle checkbox")

                            -- Quotes
                            map_with_plug({ "n", "x" }, "smq", "<Plug>(MarkdownPlusToggleQuote)", "Toggle blockquote")

                            -- Callouts
                            map_with_plug({ "n", "x" }, "smQ", "<Plug>(MarkdownPlusInsertCallout)", "Insert/wrap callout")

                            -- Footnotes
                            map_with_plug("n", "smff", "<Plug>(MarkdownPlusFootnoteInsert)", "Insert footnote")
                            map_with_plug("n", "smfd", "<Plug>(MarkdownPlusFootnoteDelete)", "Delete footnote")

                            -- Tables
                            map_with_plug("n", "smtt", "<Plug>(markdown-plus-table-create)", "Create new table")
                            map_with_plug("n", "smtf", "<Plug>(markdown-plus-table-format)", "Format table")
                            map_with_plug("n", "<s-down>", "<Plug>(markdown-plus-table-insert-row-below)", "Insert row below")
                            map_with_plug("n", "<s-up>", "<Plug>(markdown-plus-table-insert-row-above)", "Insert row above")
                            map_with_plug("n", "dr", "<Plug>(markdown-plus-table-delete-row)", "Delete row")
                            map_with_plug("n", "yr", "<Plug>(markdown-plus-table-duplicate-row)", "Duplicate row")
                            map_with_plug("n", "<s-right>", "<Plug>(markdown-plus-table-insert-column-right)", "Insert column right")
                            map_with_plug("n", "<s-left>", "<Plug>(markdown-plus-table-insert-column-left)", "Insert column left")
                            map_with_plug("n", "dc", "<Plug>(markdown-plus-table-delete-column)", "Delete column")
                            map_with_plug("n", "yc", "<Plug>(markdown-plus-table-duplicate-column)", "Duplicate column")
                            map_with_plug("n", "smta", "<Plug>(markdown-plus-table-toggle-cell-alignment)", "Toggle cell alignment")
                            map_with_plug("n", "dC", "<Plug>(markdown-plus-table-clear-cell)", "Clear cell content")
                            map_with_plug("n", "<c-up>", "<Plug>(markdown-plus-table-move-row-up)", "Move row up")
                            map_with_plug("n", "<c-down>", "<Plug>(markdown-plus-table-move-row-down)", "Move row down")
                            map_with_plug("n", "<c-left>", "<Plug>(markdown-plus-table-move-column-left)", "Move column left")
                            map_with_plug("n", "<c-right>", "<Plug>(markdown-plus-table-move-column-right)", "Move column right")
                            map_with_plug("n", "smtT", "<Plug>(markdown-plus-table-transpose)", "Transpose table")
                            map_with_plug("n", "smts", "<Plug>(markdown-plus-table-sort-ascending)", "Sort table by column (ascending)")
                            map_with_plug("n", "smtS", "<Plug>(markdown-plus-table-sort-descending)", "Sort table by column (descending)")
                            map_with_plug("n", "smtv", "<Plug>(markdown-plus-table-to-csv)", "Convert table to CSV")
                            map_with_plug("n", "smtV", "<Plug>(markdown-plus-table-from-csv)", "Convert CSV to table")
                            map_with_plug("n", "<left>", "<Plug>(markdown-plus-table-nav-left)", "Navigate to cell left or move cursor left")
                            map_with_plug("n", "<right>", "<Plug>(markdown-plus-table-nav-right)", "Navigate to cell right or move cursor right")
                            map_with_plug("n", "<up>", "<Plug>(markdown-plus-table-nav-up)", "Navigate to cell above or move cursor up")
                            map_with_plug("n", "<down>", "<Plug>(markdown-plus-table-nav-down)", "Navigate to cell below or move cursor down")
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
            features = {
                list_management = false,
            },
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
