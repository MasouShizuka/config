local bhu = require("plugins.bars_and_lines.heirline.utils")
local colors = require("utils.colors")
local icons = require("utils.icons")

return {
    static = {
        mode_names = {
            n = "NORMAL",
            no = "OP",
            nov = "OP",
            noV = "OP",
            ["no\22"] = "OP",
            niI = "NORMAL",
            niR = "NORMAL",
            niV = "NORMAL",
            nt = "NORMAL",
            ntT = "NORMAL",
            v = "VISUAL",
            vs = "VISUAL",
            V = "V-LINE",
            Vs = "V-LINE",
            ["\22"] = "V-BLOCK",
            ["\22s"] = "V-BLOCK",
            s = "SELECT",
            S = "SELECT",
            ["\19"] = "BLOCK",
            i = "INSERT",
            ic = "INSERT",
            ix = "INSERT",
            R = "REPLACE",
            Rc = "REPLACE",
            Rx = "REPLACE",
            Rv = "V-REPLACE",
            Rvc = "V-REPLACE",
            Rvx = "V-REPLACE",
            c = "COMMAND",
            cv = "COMMAND",
            r = "ENTER",
            rm = "MORE",
            ["r?"] = "CONFIRM",
            ["!"] = "SHELL",
            t = "TERMINAL",
        },
        mode_colors_map = {
            n = colors.colors.green,
            i = colors.colors.blue,
            v = colors.colors.yellow,
            V = colors.colors.yellow,
            ["\22"] = colors.colors.yellow,
            c = colors.colors.purple,
            s = colors.colors.yellow,
            S = colors.colors.yellow,
            ["\19"] = colors.colors.yellow,
            R = colors.colors.red,
            r = colors.colors.red,
            ["!"] = colors.colors.green,
            t = colors.colors.blue,
        },
        mode_color = function(self)
            local mode = require("heirline.conditions").is_active() and vim.fn.mode() or "n"
            return self.mode_colors_map[mode]
        end,
    },
    update = {
        "ModeChanged",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
        pattern = "*:*",
    },

    bhu.surround_with_condition(
        { icons.surround.left_half_circle_thick, icons.surround.right_half_circle_thick },
        function(self) return self:mode_color() end,
        {
            init = function(self)
                self.mode = vim.fn.mode(1)
            end,
            provider = function(self)
                return icons.misc.circle .. self.mode_names[self.mode]
            end,
            hl = { fg = colors.colors.black },
        }
    ),
}
