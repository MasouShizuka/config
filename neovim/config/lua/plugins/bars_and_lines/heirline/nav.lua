local bhu = require("plugins.bars_and_lines.heirline.utils")
local colors = require("utils.colors")
local icons = require("utils.icons")

local M = {}

M.ruler = {
    update = { "CursorMoved", "ModeChanged" },

    bhu.padding_after({
        condition = function(self)
            local mode = vim.fn.mode()
            self.is_mode_v = mode:find("v")
            self.is_mode_V = mode:find("V")
            return self.is_mode_v or self.is_mode_V
        end,
        provider = function(self)
            if self.is_mode_v then
                return string.format("%s%s", icons.misc.order_alphabetical_ascending, vim.fn.wordcount().visual_chars)
            elseif self.is_mode_V then
                local visual_start = vim.fn.line("v")
                local visual_end = vim.fn.line(".")
                local lines = visual_start <= visual_end and visual_end - visual_start + 1 or visual_start - visual_end + 1
                return string.format("%s %s", icons.misc.line_number, lines)
            end

            return ""
        end,
    }),
    {
        provider = icons.misc.text .. "%l:%v %P",
    },
}

M.scrollbar = {
    static = {
        sbar = {
            icons.misc.horizontal_one_eighth_block_2,
            icons.misc.horizontal_one_eighth_block_3,
            icons.misc.horizontal_one_eighth_block_4,
            icons.misc.horizontal_one_eighth_block_5,
            icons.misc.horizontal_one_eighth_block_6,
            icons.misc.horizontal_one_eighth_block_7,
        },
    },
    init = function(self)
        self.row = vim.api.nvim_win_get_cursor(0)[1]
        self.line_count = vim.api.nvim_buf_line_count(0)
    end,
    provider = function(self)
        local i = math.floor((self.row - 1) / self.line_count * #self.sbar) + 1
        return self.sbar[i]:rep(2)
    end,
    hl = { fg = colors.colors.blue, bg = colors.colors.gray },
    update = "CursorMoved",
}

return M
