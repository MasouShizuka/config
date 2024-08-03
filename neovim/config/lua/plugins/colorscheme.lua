local colors = require("utils.colors")
local environment = require("utils.environment")
local utils = require("utils")

return {
    {
        "catppuccin/nvim",
        enabled = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        name = "catppuccin",
        opts = {
            transparent_background = true, -- disables setting the background color.
            no_italic = true,              -- Force no italic
            custom_highlights = function(C)
                local ch = {}
                if environment.is_undercurl_available then
                    ch = vim.tbl_deep_extend("force", ch, {
                        DiagnosticUnderlineError = { style = { "undercurl" } },
                        DiagnosticUnderlineHint = { style = { "undercurl" } },
                        DiagnosticUnderlineInfo = { style = { "undercurl" } },
                        DiagnosticUnderlineWarn = { style = { "undercurl" } },
                    })
                else
                    ch = vim.tbl_deep_extend("force", ch, {
                        SpellBad = { style = { "underline" } },
                        SpellCap = { style = { "underline" } },
                        SpellLocal = { style = { "underline" } },
                        SpellRare = { style = { "underline" } },
                    })
                end
                return ch
            end,
        },
    },

    {
        "ellisonleao/gruvbox.nvim",
        enabled = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        opts = function()
            local overrides = {
                CursorLineNr = { bg = "none" },
                LspReferenceRead = { bg = colors.get_color("gray", "gruvbox") },
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
            if utils.is_available("nvim-tree.lua") then
                overrides.NvimTreeOpenedFile = { fg = colors.get_color("orange", "gruvbox") }
            end
            if utils.is_available("nvim-treesitter-context") then
                overrides.TreesitterContextBottom = { underline = true }
                overrides.TreesitterContextLineNumber = { fg = colors.get_color("purple", "gruvbox") }
            end

            return {
                undercurl = environment.is_undercurl_available,
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = false,
                    folds = false,
                },
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
                -- Style to be applied to different syntax groups
                -- Value is any valid attr-list value for `:help nvim_set_hl`
                comments = { italic = false },
                keywords = { italic = false },
                -- Background styles. Can be "dark", "transparent" or "normal"
                sidebars = "transparent", -- style for sidebars, see below
                floats = "transparent",   -- style for floating windows
            },
            --- You can override specific highlights to use other groups or a hex color
            --- function will be called with a Highlights and ColorScheme table
            ---@param highlights tokyonight.Highlights
            ---@param colors ColorScheme
            on_highlights = function(hl, c)
                hl.DiagnosticUnnecessary = vim.tbl_deep_extend("force", hl.DiagnosticUnnecessary or {}, { fg = c[colors.get_colorscheme_color("tokyonight", "gray")] })
                hl.MatchParen = vim.tbl_deep_extend("force", hl.MatchParen or {}, { bg = c[colors.get_colorscheme_color("tokyonight", "gray")] })
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
                if utils.is_available("nvim-tree.lua") then
                    hl.NvimTreeNormal = { link = "NvimTreeNormalFloat" }
                    hl.NvimTreeNormalNC = { link = "NvimTreeNormalFloat" }
                    hl.NvimTreeOpenedFile = { fg = c[colors.get_colorscheme_color("tokyonight", "purple")] }
                    hl.NvimTreeOpenedHL = { link = "NvimTreeOpenedFile" }
                end
                if utils.is_available("nvim-treesitter-context") then
                    hl.TreesitterContextBottom = vim.tbl_deep_extend("force", hl.TreesitterContextBottom or {}, { underline = true })
                    hl.TreesitterContextLineNumber = vim.tbl_deep_extend("force", hl.TreesitterContextLineNumber or {}, { fg = c[colors.get_colorscheme_color("tokyonight", "purple")] })
                end
                if utils.is_available("telescope.nvim") then
                    hl.TelescopeSelection = vim.tbl_deep_extend("force", hl.TelescopeSelection or {}, { bg = c[colors.get_colorscheme_color("tokyonight", "black")] })
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
        lazy = true,
        opts = function()
            local highlights = {
                CursorLineNr = { fg = "${purple}" },
                DiagnosticUnderlineError = { sp = "${red}", undercurl = true },
                DiagnosticUnderlineWarn = { sp = "${yellow}", undercurl = true },
                DiagnosticUnderlineInfo = { sp = "${blue}", undercurl = true },
                DiagnosticUnderlineHint = { sp = "${cyan}", undercurl = true },
                MatchParen = { bg = "${gray}" },
                PmenuThumb = { bg = "${gray}" },
                SpellBad = { sp = "${red}", undercurl = true },
                SpellCap = { sp = "${yellow}", undercurl = true },
                SpellLocal = { sp = "${blue}", undercurl = true },
                SpellRare = { sp = "${green}", undercurl = true },
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
            if utils.is_available("nvim-tree.lua") then
                highlights.NvimTreeOpenedHL = { link = "NvimTreeOpenedFile" }
            end
            if utils.is_available("nvim-treesitter-context") then
                highlights.TreesitterContextBottom = { underline = true }
                highlights.TreesitterContextLineNumber = { fg = "${purple}" }
            end

            return {
                highlights = highlights,
                options = {
                    cursorline = true,
                    transparency = true,
                },
            }
        end,
    },

    {
        "projekt0n/github-nvim-theme",
        config = function(_, opts)
            require("github-theme").setup(opts)
        end,
        enabled = not environment.is_vscode,
        event = {
            "User ColorschemePre",
        },
        lazy = true,
        opts = function()
            local groups = {
                all = {
                    TabLineFill = { bg = "none" },
                },
            }
            if not environment.is_undercurl_available then
                groups = vim.tbl_deep_extend("force", groups,
                    {
                        all = {
                            DiagnosticUnderlineError = { style = "underline" },
                            DiagnosticUnderlineWarn = { style = "underline" },
                            DiagnosticUnderlineInfo = { style = "underline" },
                            DiagnosticUnderlineHint = { style = "underline" },
                            SpellBad = { style = "underline" },
                            SpellCap = { style = "underline" },
                            SpellLocal = { style = "underline" },
                            SpellRare = { style = "underline" },
                        },
                    }
                )
            end
            if utils.is_available("nvim-tree.lua") then
                groups = vim.tbl_deep_extend("force", groups,
                    {
                        all = {
                            NvimTreeOpenedHL = { link = "NvimTreeOpenedFile" },
                        },
                    }
                )
            end
            if utils.is_available("nvim-treesitter-context") then
                groups = vim.tbl_deep_extend("force", groups,
                    {
                        all = {
                            TreesitterContextBottom = { style = "underline" },
                            TreesitterContextLineNumber = { fg = "palette." .. colors.get_colorscheme_color("github", "purple") },
                        },
                    }
                )
            end

            return {
                options = {
                    transparent = true, -- Disable setting bg (make neovim's background transparent)
                },
                groups = groups,
            }
        end,
    },
}
