local environment = require("utils.environment")

return {
    {
        "ellisonleao/gruvbox.nvim",
        enabled = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        opts = function()
            local colors = require("utils.colors")
            local utils = require("utils")

            local overrides = {
                CursorLineNr = { bg = "none" },
                LspReferenceRead = { bg = colors.get_color("gray", "gruvbox") },
                LspReferenceText = { bg = colors.get_color("gray", "gruvbox") },
                LspReferenceWrite = { bg = colors.get_color("gray", "gruvbox") },
                TabLineFill = { bg = "none" },
                WinBar = { bg = "none" },
                WinBarNC = { bg = "none" },
            }

            if not environment.is_undercurl_available then
                overrides = vim.tbl_deep_extend("force", overrides, {
                    GruvboxRedUnderline = { undercurl = false, underline = true },
                    GruvboxGreenUnderline = { undercurl = false, underline = true },
                    GruvboxYellowUnderline = { undercurl = false, underline = true },
                    GruvboxBlueUnderline = { undercurl = false, underline = true },
                    GruvboxPurpleUnderline = { undercurl = false, underline = true },
                    GruvboxAquaUnderline = { undercurl = false, underline = true },
                    GruvboxOrangeUnderline = { undercurl = false, underline = true },
                })
            end

            if utils.is_available("flash.nvim") then
                overrides.FlashBackdrop = { link = "Comment" }
                overrides.FlashLabel = { bg = colors.get_color("red", "gruvbox"), bold = true }
            end

            if utils.is_available("gitsigns.nvim") then
                overrides.GitSignsChange = { link = "GruvboxBlue" }
            end

            if utils.is_available("nvim-treesitter-context") then
                overrides.TreesitterContextBottom = { underline = true }
                overrides.TreesitterContextLineNumber = { fg = colors.get_color("purple", "gruvbox") }
            end

            return {
                undercurl = environment.is_undercurl_available,
                overrides = overrides,
                transparent_mode = true,
            }
        end,
    },

    {
        "folke/tokyonight.nvim",
        enabled = not environment.is_vscode,
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

                hl.DiagnosticError = vim.tbl_deep_extend("force", hl.DiagnosticError or {}, { fg = c[colors.get_color_name("tokyonight", "red")] })
                hl.DiagnosticInfo = vim.tbl_deep_extend("force", hl.DiagnosticInfo or {}, { fg = c[colors.get_color_name("tokyonight", "blue")] })
                hl.DiagnosticUnnecessary = vim.tbl_deep_extend("force", hl.DiagnosticUnnecessary or {}, { fg = c.fg_dark })
                hl.DiffAdd = { link = "diffAdded" }
                hl.DiffChange = { link = "diffChanged" }
                hl.DiffDelete = { link = "diffRemoved" }
                hl.LspKindFile = { fg = c[colors.get_color_name("tokyonight", "orange")] }
                hl.MatchParen = vim.tbl_deep_extend("force", hl.MatchParen or {}, { bg = c[colors.get_color_name("tokyonight", "gray")] })
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
                    hl.BlinkCmpKindVariable = { fg = c[colors.get_color_name("tokyonight", "red")] }
                end

                if utils.is_available("nvim-cmp") then
                    hl.CmpItemKindVariable = { fg = c[colors.get_color_name("tokyonight", "red")] }
                end

                if utils.is_available("nvim-treesitter-context") then
                    hl.TreesitterContextBottom = vim.tbl_deep_extend("force", hl.TreesitterContextBottom or {}, { underline = true })
                    hl.TreesitterContextLineNumber = vim.tbl_deep_extend("force", hl.TreesitterContextLineNumber or {}, { fg = c[colors.get_color_name("tokyonight", "purple")] })
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
        enabled = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        opts = function()
            local colors = require("utils.colors")
            local utils = require("utils")

            local highlights = {
                CursorLineNr = { fg = colors.get_color("purple", "onedark") },
                DiagnosticUnderlineError = { sp = colors.get_color("red", "onedark"), undercurl = true },
                DiagnosticUnderlineWarn = { sp = colors.get_color("yellow", "onedark"), undercurl = true },
                DiagnosticUnderlineInfo = { sp = colors.get_color("blue", "onedark"), undercurl = true },
                DiagnosticUnderlineHint = { sp = colors.get_color("cyan", "onedark"), undercurl = true },
                MatchParen = { bg = colors.get_color("gray", "onedark") },
                PmenuThumb = { bg = colors.get_color("gray", "onedark") },
                SpellBad = { sp = colors.get_color("red", "onedark"), undercurl = true },
                SpellCap = { sp = colors.get_color("yellow", "onedark"), undercurl = true },
                SpellLocal = { sp = colors.get_color("blue", "onedark"), undercurl = true },
                SpellRare = { sp = colors.get_color("green", "onedark"), undercurl = true },
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
                highlights.TreesitterContextLineNumber = { fg = colors.get_color("purple", "onedark") }
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
