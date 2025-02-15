local colors = require("utils.colors")
local icons = require("utils.icons")

return {
    condition = function(self)
        return package.loaded["conform"]
    end,
    provider = function(self)
        local names = {}
        for _, formatter in ipairs(require("conform").list_formatters(0)) do
            names[#names + 1] = formatter.name
        end
        return icons.misc.format_list_text .. table.concat(names, ",")
    end,
    hl = { fg = colors.colors.yellow },
    update = "BufEnter",
}
