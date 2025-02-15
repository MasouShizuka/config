local bhu = require("plugins.bars_and_lines.heirline.utils")
local colors = require("utils.colors")
local icons = require("utils.icons")

local M = {}

M.macro = {
    condition = function(self)
        return vim.fn.reg_recording() ~= ""
    end,
    update = { "RecordingEnter", "RecordingLeave" },

    {
        provider = icons.misc.record,
        hl = { fg = colors.colors.orange, bold = true },
    },
    bhu.surround_with_condition({ "[", "]" }, nil, {
        provider = function(self)
            return vim.fn.reg_recording()
        end,
        hl = { fg = colors.colors.green, bold = true },
    }),
}

M.search_count = {
    condition = function(self)
        if vim.v.hlsearch == 0 then
            return false
        end

        local ok, search = pcall(vim.fn.searchcount)
        if ok and type(search) == "table" and search.total then
            self.search = search
            return true
        end

        return false
    end,
    provider = function(self)
        local search = self.search
        return string.format(
            "[%s%d/%s%d]",
            search.current > search.maxcount and ">" or "",
            math.min(search.current, search.maxcount),
            search.incomplete == 2 and ">" or "",
            math.min(search.total, search.maxcount)
        )
    end,
    hl = { fg = colors.colors.yellow },
}


M.show_cmd = {
    condition = function()
        return vim.opt.showcmdloc:get() == "statusline"
    end,
    provider = "%0.9(%S%)",
}

return M
