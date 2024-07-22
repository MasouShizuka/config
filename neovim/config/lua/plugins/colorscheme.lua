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
                return {
                    SpellBad = { fg = C[colors.get_colorscheme_color_name("catppuccin", "red")], underline = true },
                    SpellCap = { fg = C[colors.get_colorscheme_color_name("catppuccin", "yellow")], underline = true },
                    SpellLocal = { fg = C[colors.get_colorscheme_color_name("catppuccin", "blue")], underline = true },
                    SpellRare = { fg = C[colors.get_colorscheme_color_name("catppuccin", "green")], underline = true },
                }
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
            local gruvbox = require("gruvbox")

            local overrides = {
                CursorLineNr = { bg = "none" },
                GruvboxRedUnderline = { underline = true },
                GruvboxYellowUnderline = { underline = true },
                GruvboxBlueUnderline = { underline = true },
                GruvboxAquaUnderline = { underline = true },
                LspReferenceRead = { bg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "gray")] },
                LspReferenceWrite = { bg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "gray")] },
                TabLineFill = { bg = "none" },
                WinBar = { bg = "none" },
                WinBarNC = { bg = "none" },
            }
            if utils.is_available("dashboard-nvim") then
                overrides["DashboardFooter"] = { fg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "blue")] }
                overrides["DashboardIcon"] = { fg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "purple")] }
                overrides["DashboardKey"] = { fg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "orange")] }
            end
            if utils.is_available("flash.nvim") then
                overrides["FlashBackdrop"] = { link = "Comment" }
                overrides["FlashLabel"] = { bg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "red")], bold = true }
            end
            if utils.is_available("nvim-cmp") then
                overrides["CmpItemMenu"] = { fg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "purple")] }
            end
            if utils.is_available("nvim-tree.lua") then
                overrides["NvimTreeOpenedFile"] = { fg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "orange")] }
            end
            if utils.is_available("nvim-treesitter-context") then
                overrides["TreesitterContextBottom"] = { underline = true }
                overrides["TreesitterContextLineNumber"] = { fg = gruvbox.palette[colors.get_colorscheme_color_name("gruvbox", "purple")] }
            end

            return {
                undercurl = false,
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
                hl.DiagnosticUnderlineError = { underline = true }
                hl.DiagnosticUnderlineWarn = { underline = true }
                hl.DiagnosticUnderlineInfo = { underline = true }
                hl.DiagnosticUnderlineHint = { underline = true }
                hl.MatchParen = { bg = c[colors.get_colorscheme_color_name("tokyonight", "gray")] }
                hl.SpellBad = { underline = true }
                hl.SpellCap = { underline = true }
                hl.SpellLocal = { underline = true }
                hl.SpellRare = { underline = true }
                hl.StatusLine = { bg = "none" }
                hl.StatusLineNC = { bg = "none" }
                hl.TabLineFill = { bg = "none" }
                if utils.is_available("nvim-cmp") then
                    hl["CmpItemMenu"] = { fg = c[colors.get_colorscheme_color_name("tokyonight", "purple")] }
                end
                if utils.is_available("nvim-tree.lua") then
                    hl["NvimTreeOpenedHL"] = { link = "NvimTreeOpenedFile" }
                end
                if utils.is_available("nvim-treesitter-context") then
                    hl["TreesitterContextBottom"] = { underline = true }
                    hl["TreesitterContextLineNumber"] = { fg = c[colors.get_colorscheme_color_name("tokyonight", "purple")] }
                end
                if utils.is_available("telescope.nvim") then
                    hl["TelescopeSelection"] = { fg = c[colors.get_colorscheme_color_name("tokyonight", "orange")] }
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
                DiagnosticUnderlineError = { underline = true },
                DiagnosticUnderlineWarn = { underline = true },
                DiagnosticUnderlineInfo = { underline = true },
                DiagnosticUnderlineHint = { underline = true },
                MatchParen = { bg = "${gray}" },
                SpellBad = { fg = "${red}", sp = "${red}", underline = true },
                SpellCap = { fg = "${red}", sp = "${red}", underline = true },
                SpellLocal = { fg = "${red}", sp = "${red}", underline = true },
                SpellRare = { fg = "${red}", sp = "${red}", underline = true },
            }
            if utils.is_available("dashboard-nvim") then
                highlights["DashboardHeader"] = { fg = "${yellow}" }
                highlights["DashboardIcon"] = { fg = "${purple}" }
                highlights["DashboardKey"] = { fg = "${red}" }
            end
            if utils.is_available("nvim-cmp") then
                highlights["CmpItemMenu"] = { fg = "${purple}" }
            end
            if utils.is_available("nvim-tree.lua") then
                highlights["NvimTreeOpenedHL"] = { link = "NvimTreeOpenedFile" }
            end
            if utils.is_available("nvim-treesitter-context") then
                highlights["TreesitterContextBottom"] = { underline = true }
                highlights["TreesitterContextLineNumber"] = { fg = "${purple}" }
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
}
