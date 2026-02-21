local environment = require("utils.environment")

return {
    {
        "catppuccin/nvim",
        cond = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        name = "catppuccin",
        opts = function()
            local underlines
            if environment.is_undercurl_available then
                underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    warnings = { "undercurl" },
                    information = { "undercurl" },
                    ok = { "undercurl" },
                }
            end

            return {
                transparent_background = true, -- disables setting the background color.
                float = {
                    transparent = true,        -- enable transparent floating windows
                },
                lsp_styles = {                 -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
                    underlines = underlines,
                },
                highlight_overrides = {
                    all = function(c)
                        local colors = require("utils.colors")
                        local utils = require("utils")

                        local overrides = {}

                        if utils.is_available("nvim-treesitter-context") then
                            overrides.TreesitterContextBottom = { underline = true, sp = colors.get_color(colors.colors.white, "catppuccin") }
                        end

                        if utils.is_available("flash.nvim") then
                            overrides.FlashLabel = {
                                bg = colors.get_color(colors.colors.red, "catppuccin"),
                                bold = true,
                                fg = colors.get_color(colors.colors.black, "catppuccin"),
                            }
                        end

                        return overrides
                    end,
                },
            }
        end,
    },

    {
        "folke/tokyonight.nvim",
        cond = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        opts = {
            transparent = true, -- Enable this to disable setting the background color
            styles = {
                -- Background styles. Can be "dark", "transparent" or "normal"
                sidebars = "transparent", -- style for sidebars, see below
                floats = "transparent",   -- style for floating windows
            },
            --- You can override specific highlights to use other groups or a hex color
            --- function will be called with a Highlights and ColorScheme table
            ---@param highlights tokyonight.Highlights
            ---@param colors ColorScheme
            on_highlights = function(hl, c)
                local colors = require("utils.colors")
                local utils = require("utils")

                hl.DiagnosticError = vim.tbl_deep_extend("force", hl.DiagnosticError or {}, { fg = c[colors.get_color_name(colors.colors.red, "tokyonight")] })
                hl.DiagnosticInfo = vim.tbl_deep_extend("force", hl.DiagnosticInfo or {}, { fg = c[colors.get_color_name(colors.colors.blue, "tokyonight")] })
                hl.DiagnosticUnnecessary = vim.tbl_deep_extend("force", hl.DiagnosticUnnecessary or {}, { fg = c.fg_dark })
                hl.DiffAdd = { link = "diffAdded" }
                hl.DiffChange = { link = "diffChanged" }
                hl.DiffDelete = { link = "diffRemoved" }
                hl.LspKindFile = { fg = c[colors.get_color_name(colors.colors.orange, "tokyonight")] }
                hl.MatchParen = vim.tbl_deep_extend("force", hl.MatchParen or {}, { bg = c[colors.get_color_name(colors.colors.gray, "tokyonight")] })
                hl.StatusLine = vim.tbl_deep_extend("force", hl.StatusLine or {}, { bg = "none" })
                hl.StatusLineNC = vim.tbl_deep_extend("force", hl.StatusLineNC or {}, { bg = "none" })
                hl.TabLineFill = vim.tbl_deep_extend("force", hl.TabLineFill or {}, { bg = "none" })

                if not environment.is_undercurl_available then
                    hl.DiagnosticUnderlineError = vim.tbl_deep_extend("force", hl.DiagnosticUnderlineError or {}, { undercurl = false, underline = true })
                    hl.DiagnosticUnderlineWarn = vim.tbl_deep_extend("force", hl.DiagnosticUnderlineWarn or {}, { undercurl = false, underline = true })
                    hl.DiagnosticUnderlineInfo = vim.tbl_deep_extend("force", hl.DiagnosticUnderlineInfo or {}, { undercurl = false, underline = true })
                    hl.DiagnosticUnderlineHint = vim.tbl_deep_extend("force", hl.DiagnosticUnderlineHint or {}, { undercurl = false, underline = true })
                    hl.SpellBad = vim.tbl_deep_extend("force", hl.SpellBad or {}, { undercurl = false, underline = true })
                    hl.SpellCap = vim.tbl_deep_extend("force", hl.SpellCap or {}, { undercurl = false, underline = true })
                    hl.SpellLocal = vim.tbl_deep_extend("force", hl.SpellLocal or {}, { undercurl = false, underline = true })
                    hl.SpellRare = vim.tbl_deep_extend("force", hl.SpellRare or {}, { undercurl = false, underline = true })
                end

                if utils.is_available("blink.cmp") then
                    hl.BlinkCmpKindVariable = { fg = c[colors.get_color_name(colors.colors.red, "tokyonight")] }
                end

                if utils.is_available("nvim-cmp") then
                    hl.CmpItemKindVariable = { fg = c[colors.get_color_name(colors.colors.red, "tokyonight")] }
                end

                if utils.is_available("nvim-treesitter-context") then
                    hl.TreesitterContextBottom = vim.tbl_deep_extend("force", hl.TreesitterContextBottom or {}, { underline = true })
                    hl.TreesitterContextLineNumber = vim.tbl_deep_extend("force", hl.TreesitterContextLineNumber or {}, { fg = c[colors.get_color_name(colors.colors.purple, "tokyonight")] })
                end
            end,
        },
    },

    {
        "olimorris/onedarkpro.nvim",
        cmd = {
            "OnedarkproCache",
            "OnedarkproClean",
            "OnedarkproColors",
            "OnedarkproExportToAlacritty",
            "OnedarkproExportToFoot",
            "OnedarkproExportToKitty",
            "OnedarkproExportToWezterm",
            "OnedarkproExportToWindowsTerminal",
            "OnedarkproExportToRio",
            "OnedarkproExportToZellij",
        },
        cond = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        opts = function()
            local colors = require("utils.colors")
            local utils = require("utils")

            local highlights = {
                CursorLineNr = { fg = colors.get_color(colors.colors.purple, "onedark") },
                DiagnosticUnderlineError = { sp = colors.get_color(colors.colors.red, "onedark"), undercurl = true },
                DiagnosticUnderlineWarn = { sp = colors.get_color(colors.colors.yellow, "onedark"), undercurl = true },
                DiagnosticUnderlineInfo = { sp = colors.get_color(colors.colors.blue, "onedark"), undercurl = true },
                DiagnosticUnderlineHint = { sp = colors.get_color(colors.colors.cyan, "onedark"), undercurl = true },
                MatchParen = { bg = colors.get_color(colors.colors.gray, "onedark") },
                PmenuThumb = { bg = colors.get_color(colors.colors.gray, "onedark") },
                SpellBad = { sp = colors.get_color(colors.colors.red, "onedark"), undercurl = true },
                SpellCap = { sp = colors.get_color(colors.colors.yellow, "onedark"), undercurl = true },
                SpellLocal = { sp = colors.get_color(colors.colors.blue, "onedark"), undercurl = true },
                SpellRare = { sp = colors.get_color(colors.colors.green, "onedark"), undercurl = true },
            }

            if not environment.is_undercurl_available then
                highlights = vim.tbl_deep_extend("force", highlights, {
                    DiagnosticUnderlineError = { undercurl = false, underline = true },
                    DiagnosticUnderlineWarn = { undercurl = false, underline = true },
                    DiagnosticUnderlineInfo = { undercurl = false, underline = true },
                    DiagnosticUnderlineHint = { undercurl = false, underline = true },
                    SpellBad = { undercurl = false, underline = true },
                    SpellCap = { undercurl = false, underline = true },
                    SpellLocal = { undercurl = false, underline = true },
                    SpellRare = { undercurl = false, underline = true },
                })
            end

            if utils.is_available("nvim-treesitter-context") then
                highlights.TreesitterContextBottom = { underline = true }
                highlights.TreesitterContextLineNumber = { fg = colors.get_color(colors.colors.purple, "onedark") }
            end

            return {
                highlights = highlights, -- Override default highlight groups or create your own
                styles = {               -- For example, to apply bold and italic, use "bold,italic"
                    types = "NONE",
                    methods = "NONE",
                    numbers = "NONE",
                    strings = "NONE",
                    comments = "italic",
                    keywords = "bold,italic",
                    constants = "NONE",
                    functions = "italic",
                    operators = "NONE",
                    variables = "NONE",
                    parameters = "NONE",
                    conditionals = "italic",
                    virtual_text = "NONE",
                },
                options = {
                    cursorline = true,   -- Use cursorline highlighting?
                    transparency = true, -- Use a transparent background?
                },
            }
        end,
    },
}
