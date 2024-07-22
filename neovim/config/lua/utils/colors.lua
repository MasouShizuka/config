local M = {}

M.colors = {
    black      = "black",
    blue       = "blue",
    cyan       = "cyan",
    gray       = "gray",
    green      = "green",
    orange     = "orange",
    purple     = "purple",
    red        = "red",
    white      = "white",
    yellow     = "yellow",

    git_add    = "git_add",
    git_change = "git_change",
    git_delete = "git_delete",
}

M.highlights = {
    [M.colors.black]      = "EndOfBuffer",
    [M.colors.blue]       = "DiagnosticInfo",
    [M.colors.cyan]       = "DiagnosticHint",
    [M.colors.gray]       = "NonText",
    [M.colors.green]      = "String",
    [M.colors.orange]     = "Constant",
    [M.colors.purple]     = "Statement",
    [M.colors.red]        = "DiagnosticError",
    [M.colors.white]      = "Conceal",
    [M.colors.yellow]     = "DiagnosticWarn",

    [M.colors.git_add]    = "diffAdded",
    [M.colors.git_change] = "diffChanged",
    [M.colors.git_delete] = "diffRemoved",
}

M.colorscheme = {
    catppuccin = {
        func = function(name) return require("catppuccin.palettes").get_palette()[name] end,
        map = {
            black  = "base",
            cyan   = "teal",
            gray   = "surface1",
            orange = "peach",
            purple = "mauve",
            white  = "text",
        },
        package_name = "catppuccin",
    },
    gruvbox = {
        func = function(name) return require("gruvbox").palette[name] end,
        map = {
            black  = "dark0",
            blue   = "bright_blue",
            cyan   = "bright_aqua",
            gray   = "dark2",
            green  = "bright_green",
            orange = "bright_orange",
            purple = "bright_purple",
            red    = "bright_red",
            white  = "light0",
            yellow = "bright_yellow",
        },
        package_name = "gruvbox",
    },
    tokyonight = {
        func = function(name) return require("tokyonight.colors").setup()[name] end,
        map = {
            black = "bg",
            gray  = "dark3",
            white = "fg",
        },
        package_name = "tokyonight",
    },
    onedark = {
        func = function(name) return require("onedarkpro.helpers").get_preloaded_colors()[name] end,
        map = {
            black = "bg",
        },
        package_name = "onedarkpro",
    },
}

M.get_colorscheme_color_name = function(colorscheme, color_name)
    local t = M.colorscheme[colorscheme]
    if t then
        local colorscheme_color_name = t.map[color_name]
        if colorscheme_color_name then
            return colorscheme_color_name
        end
    end

    return M.colors[color_name]
end

M.get_color = function(name)
    local colors_name = string.lower(vim.g.colors_name)
    for colorscheme, t in pairs(M.colorscheme) do
        if colors_name:match(colorscheme) then
            name = M.get_colorscheme_color_name(colorscheme, name)

            local func = t.func
            if func then
                local color = func(name)
                if color then
                    return color
                end
            end

            break
        end
    end

    local hl = vim.api.nvim_get_hl(0, { name = M.highlights[name], link = false })
    if hl.fg then
        return string.format("#%06x", hl.fg)
    elseif hl.bg then
        return string.format("#%06x", hl.bg)
    end

    return name
end

return M
