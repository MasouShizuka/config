local colors = require("utils.colors")
local icons = require("utils.icons")

return {
    condition = function(self)
        if not package.loaded["dap"] then
            return false
        end

        self.dap = require("dap")
        return self.dap.session() ~= nil
    end,
    provider = function(self)
        return icons.misc.bug .. self.dap.status()
    end,
    hl = { fg = colors.colors.blue },
}
