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

M.color_highlight_map = {
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

    [M.colors.git_add]    = { "diffAdded", "DiffAdd" },
    [M.colors.git_change] = { "diffChanged", "DiffChange" },
    [M.colors.git_delete] = { "diffRemoved", "DiffDelete" },
}

M.colorscheme = {
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

M.get_colorscheme_color = function(colorscheme, color_name)
    local t = M.colorscheme[colorscheme]
    if t then
        local colorscheme_color_name = t.map[color_name]
        if colorscheme_color_name then
            return colorscheme_color_name
        end
    end

    return M.colors[color_name]
end

M.get_color = function(color, colorscheme)
    colorscheme = colorscheme or vim.g.colors_name or "default"

    local spec
    for c, s in pairs(M.colorscheme) do
        if colorscheme:match(c) then
            colorscheme = c
            spec = s
            break
        end
    end

    if spec then
        local func = spec.func
        if func then
            local color_value = func(M.get_colorscheme_color(colorscheme, color))
            if color_value then
                return color_value
            end
        end
    end

    local hls = M.color_highlight_map[color]
    if type(hls) == "string" then
        hls = { hls }
    end
    for _, hl in ipairs(hls) do
        local highlight = vim.api.nvim_get_hl(0, { name = hl, link = false })
        if highlight.fg then
            return string.format("#%06x", highlight.fg)
        elseif highlight.bg then
            return string.format("#%06x", highlight.bg)
        end
    end

    return color
end

return M
