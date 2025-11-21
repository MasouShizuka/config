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
                                    { "sm", buffer = args.buf, group = "markdown", mode = { "n", "x" } },
                                })
                            end

                            -- List Management
                            vim.keymap.set("i", "<cr>", function() require("markdown-plus.list.handlers").handle_enter() end, { buffer = args.buf, desc = "Auto-continue list or split content", silent = true })
                            vim.keymap.set("i", "<c-t>", function() require("markdown-plus.list.handlers").handle_tab() end, { buffer = args.buf, desc = "Indent list item", silent = true })
                            vim.keymap.set("i", "<c-d>", function() require("markdown-plus.list.handlers").handle_shift_tab() end, { buffer = args.buf, desc = "Outdent list item", silent = true })
                            vim.keymap.set("i", "<bs>", function() require("markdown-plus.list.handlers").handle_backspace() end, { buffer = args.buf, desc = "Smart backspace (remove empty list)", silent = true })
                            vim.keymap.set("n", "o", function() require("markdown-plus.list.handlers").handle_normal_o() end, { buffer = args.buf, desc = "New list item below", silent = true })
                            vim.keymap.set("n", "O", function() require("markdown-plus.list.handlers").handle_normal_O() end, { buffer = args.buf, desc = "New list item above", silent = true })
                            vim.keymap.set({ "n", "x" }, "<cr>", function()
                                local checkbox = require("markdown-plus.list.checkbox")
                                checkbox.toggle_checkbox_line()
                                checkbox.toggle_checkbox_range()
                                checkbox.toggle_checkbox_insert()
                            end, { buffer = args.buf, desc = "Toggle checkbox", silent = true })

                            -- Text Formatting
                            vim.keymap.set("n", "smb", function() require("markdown-plus.format").toggle_format_word("bold") end, { buffer = args.buf, desc = "Toggle bold formatting", silent = true })
                            vim.keymap.set("x", "smb", function() require("markdown-plus.format").toggle_format("bold") end, { buffer = args.buf, desc = "Toggle bold formatting", silent = true })
                            vim.keymap.set("n", "smi", function() require("markdown-plus.format").toggle_format_word("italic") end, { buffer = args.buf, desc = "Toggle italic formatting", silent = true })
                            vim.keymap.set("x", "smi", function() require("markdown-plus.format").toggle_format("italic") end, { buffer = args.buf, desc = "Toggle italic formatting", silent = true })
                            vim.keymap.set("n", "sms", function() require("markdown-plus.format").toggle_format_word("strikethrough") end, { buffer = args.buf, desc = "Toggle strikethrough formatting", silent = true })
                            vim.keymap.set("x", "sms", function() require("markdown-plus.format").toggle_format("strikethrough") end, { buffer = args.buf, desc = "Toggle strikethrough formatting", silent = true })
                            vim.keymap.set("n", "smc", function() require("markdown-plus.format").toggle_format_word("code") end, { buffer = args.buf, desc = "Toggle inline code formatting", silent = true })
                            vim.keymap.set("x", "smc", function() require("markdown-plus.format").toggle_format("code") end, { buffer = args.buf, desc = "Toggle inline code formatting", silent = true })
                            vim.keymap.set("x", "smC", function() require("markdown-plus.format").convert_to_code_block() end, { buffer = args.buf, desc = "Convert selection to code block", silent = true })
                            vim.keymap.set("n", "smx", function() require("markdown-plus.format").clear_formatting_word() end, { buffer = args.buf, desc = "Clear all formatting", silent = true })
                            vim.keymap.set("x", "smx", function() require("markdown-plus.format").clear_formatting() end, { buffer = args.buf, desc = "Clear all formatting", silent = true })

                            -- Headers & TOC
                            vim.keymap.set("n", "smtc", function() require("markdown-plus.headers.toc").generate_toc() end, { buffer = args.buf, desc = "Generate table of contents", silent = true })
                            vim.keymap.set("n", "smtu", function() require("markdown-plus.headers.toc").update_toc() end, { buffer = args.buf, desc = "Update table of contents", silent = true })

                            -- Links
                            vim.keymap.set("n", "sml", function() require("markdown-plus.links").insert_link() end, { buffer = args.buf, desc = "Insert markdown link", silent = true })
                            vim.keymap.set("x", "sml", function() require("markdown-plus.links").selection_to_link() end, { buffer = args.buf, desc = "Convert selection to link", silent = true })
                            vim.keymap.set("n", "smu", function() require("markdown-plus.links").auto_link_url() end, { buffer = args.buf, desc = "auto_link_url", silent = true })

                            -- Images
                            vim.keymap.set("n", "smp", function() require("markdown-plus.images").insert_image() end, { buffer = args.buf, desc = "Insert markdown image", silent = true })
                            vim.keymap.set("x", "smp", function() require("markdown-plus.images").selection_to_image() end, { buffer = args.buf, desc = "Convert selection to image", silent = true })

                            -- Quotes
                            vim.keymap.set("n", "smq", function() require("markdown-plus.quote").toggle_quote_line() end, { buffer = args.buf, desc = "Toggle blockquote", silent = true })
                            vim.keymap.set("x", "smq", function() require("markdown-plus.quote").toggle_quote() end, { buffer = args.buf, desc = "Toggle blockquote", silent = true })

                            -- Callouts
                            vim.keymap.set({ "n", "x" }, "smQ", function()
                                local callouts = require("markdown-plus.callouts")
                                callouts.insert_callout_prompt()
                                callouts.wrap_selection_in_callout()
                            end, { buffer = args.buf, desc = "Insert/wrap callout", silent = true })

                            -- Tables
                            if require("utils").is_available("which-key.nvim") then
                                require("which-key").add({
                                    { "smt", buffer = args.buf, group = "markdown table", mode = { "n", "x" } },
                                })
                            end
                            vim.keymap.set("n", "smtt", function() require("markdown-plus.table.creator").create_table_interactive() end, { buffer = args.buf, desc = "Create new table", silent = true })
                            vim.keymap.set("n", "smtf", function() require("markdown-plus.table").format_table() end, { buffer = args.buf, desc = "Format table", silent = true })
                            vim.keymap.set("n", "smtn", function() require("markdown-plus.table").normalize_table() end, { buffer = args.buf, desc = "Normalize table", silent = true })
                            vim.keymap.set("n", "<s-down>", function() require("markdown-plus.table").insert_row_below() end, { buffer = args.buf, desc = "Insert row below", silent = true })
                            vim.keymap.set("n", "<s-up>", function() require("markdown-plus.table").insert_row_above() end, { buffer = args.buf, desc = "Insert row above", silent = true })
                            vim.keymap.set("n", "dr", function() require("markdown-plus.table").delete_row() end, { buffer = args.buf, desc = "Delete row", silent = true })
                            vim.keymap.set("n", "yr", function() require("markdown-plus.table.manipulation").duplicate_row() end, { buffer = args.buf, desc = "Duplicate row", silent = true })
                            vim.keymap.set("n", "<s-right>", function() require("markdown-plus.table").insert_column_right() end, { buffer = args.buf, desc = "Insert column right", silent = true })
                            vim.keymap.set("n", "<s-left>", function() require("markdown-plus.table").insert_column_left() end, { buffer = args.buf, desc = "Insert column left", silent = true })
                            vim.keymap.set("n", "dc", function() require("markdown-plus.table").delete_column() end, { buffer = args.buf, desc = "Delete column", silent = true })
                            vim.keymap.set("n", "yc", function() require("markdown-plus.table.manipulation").duplicate_column() end, { buffer = args.buf, desc = "Duplicate column", silent = true })
                            vim.keymap.set("n", "smta", function() require("markdown-plus.table").toggle_cell_alignment() end, { buffer = args.buf, desc = "Toggle cell alignment", silent = true })
                            vim.keymap.set("n", "dC", function() require("markdown-plus.table").clear_cell() end, { buffer = args.buf, desc = "clear_cell", silent = true })
                            vim.keymap.set("n", "<c-down>", function() require("markdown-plus.table").move_row_up() end, { buffer = args.buf, desc = "Move row up", silent = true })
                            vim.keymap.set("n", "<c-up>", function() require("markdown-plus.table").move_row_down() end, { buffer = args.buf, desc = "Move row down", silent = true })
                            vim.keymap.set("n", "<c-left>", function() require("markdown-plus.table").move_column_left() end, { buffer = args.buf, desc = "Move column left", silent = true })
                            vim.keymap.set("n", "<c-right>", function() require("markdown-plus.table").move_column_right() end, { buffer = args.buf, desc = "Move column right", silent = true })
                            vim.keymap.set("n", "smtT", function() require("markdown-plus.table").transpose_table() end, { buffer = args.buf, desc = "Transpose table", silent = true })
                            vim.keymap.set("n", "smts", function() require("markdown-plus.table").sort_ascending() end, { buffer = args.buf, desc = "Sort table by column (ascending)", silent = true })
                            vim.keymap.set("n", "smtS", function() require("markdown-plus.table").sort_descending() end, { buffer = args.buf, desc = "Sort table by column (descending)", silent = true })
                            vim.keymap.set("n", "smtv", function() require("markdown-plus.table").table_to_csv() end, { buffer = args.buf, desc = "Convert table to CSV", silent = true })
                            vim.keymap.set("n", "smtV", function() require("markdown-plus.table").csv_to_table() end, { buffer = args.buf, desc = "Convert CSV to table", silent = true })
                            vim.keymap.set("n", "<left>", function() require("markdown-plus.table.navigation").move_left() end, { buffer = args.buf, desc = "Navigate table cell or fallback to left", silent = true })
                            vim.keymap.set("n", "<right>", function() require("markdown-plus.table.navigation").move_right() end, { buffer = args.buf, desc = "Navigate table cell or fallback to right", silent = true })
                            vim.keymap.set("n", "<down>", function() require("markdown-plus.table.navigation").move_down() end, { buffer = args.buf, desc = "Navigate table cell or fallback to down", silent = true })
                            vim.keymap.set("n", "<up>", function() require("markdown-plus.table.navigation").move_up() end, { buffer = args.buf, desc = "Navigate table cell or fallback to up", silent = true })
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
