local colorscheme = 'onedarkpro'

if not vim.g.neovide then
    require("onedarkpro").setup({
        dark_theme = "onedark", -- The default dark theme
        light_theme = "onelight", -- The default light theme
        caching = false, -- Use caching for the theme?
        cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/onedarkpro/"), -- The path to the cache directory
        colors = {}, -- Override default colors by specifying colors for 'onelight' or 'onedark' themes
        highlights = {}, -- Override default highlight and/or filetype groups
        filetypes = { -- Override which filetype highlight groups are loaded
            javascript = true,
            markdown = true,
            python = true,
            ruby = true,
            rust = true,
            toml = true,
            yaml = true,
        },
        plugins = { -- Override which plugin highlight groups are loaded
            -- See the Supported Plugins section for a list of available plugins
        },
        styles = { -- Choose from "bold,italic,underline"
            types = "NONE", -- Style that is applied to types
            numbers = "NONE", -- Style that is applied to numbers
            strings = "NONE", -- Style that is applied to strings
            comments = "NONE", -- Style that is applied to comments
            keywords = "NONE", -- Style that is applied to keywords
            constants = "NONE", -- Style that is applied to constants
            functions = "NONE", -- Style that is applied to functions
            operators = "NONE", -- Style that is applied to operators
            variables = "NONE", -- Style that is applied to variables
            conditionals = "NONE", -- Style that is applied to conditionals
            virtual_text = "NONE", -- Style that is applied to virtual text
        },
        options = {
            bold = false, -- Use the colorscheme's opinionated bold styles?
            italic = false, -- Use the colorscheme's opinionated italic styles?
            underline = false, -- Use the colorscheme's opinionated underline styles?
            undercurl = false, -- Use the colorscheme's opinionated undercurl styles?
            cursorline = false, -- Use cursorline highlighting?
            transparency = true, -- Use a transparent background?
            terminal_colors = false, -- Use the colorscheme's colors for Neovim's :terminal?
            window_unfocused_color = false, -- When the window is out of focus, change the normal background?
        }
    })
end

local status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not status_ok then
    vim.notify('colorscheme: ' .. colorscheme .. ' 没有找到！')
    return
end
