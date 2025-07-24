local M = {}

M.align = { provider = "%=" }

M.insert_with_child_condition = function(destination, ...)
    local heirline_utils = require("heirline.utils")

    local children = { ... }
    local new = heirline_utils.clone(destination)

    for _, child in ipairs(children) do
        local new_child = heirline_utils.clone(child)
        new[#new + 1] = new_child
    end

    local old_condition = new.condition
    local new_condition = function(self)
        if old_condition and not old_condition(self) then
            return false
        end

        for _, child in ipairs(children) do
            if child.condition and child.condition(child) then
                return true
            end
        end

        return false
    end
    new.condition = new_condition

    return new
end

M.load_colors = function()
    local function on_colorscheme()
        local colors = require("utils.colors")

        local heirline_utils = require("heirline.utils")

        local heirline_colors = {}
        for color, _ in pairs(colors.colors) do
            heirline_colors[color] = colors.get_color(color)
        end

        heirline_utils.on_colorscheme(heirline_colors)
    end

    on_colorscheme()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = on_colorscheme,
        desc = "Change the colors automatically whenever change the colorscheme",
        group = vim.api.nvim_create_augroup("Heirline", { clear = true }),
    })
end

M.padding_before = function(component, n)
    n = n or 1

    return {
        condition = component.condition,

        { provider = string.rep(" ", n) },
        component,
    }
end

M.padding_after = function(component, n)
    n = n or 1

    return {
        condition = component.condition,

        component,
        { provider = string.rep(" ", n) },
    }
end

M.surround_with_condition = function(delimiters, color, component)
    local surrounded = require("heirline.utils").surround(delimiters, color, component)
    surrounded.condition = component.condition
    return surrounded
end

return M
