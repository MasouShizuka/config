vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { silent = true })
vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { silent = true })
vim.keymap.set("x", "<C-a>", require("dial.map").inc_visual(), { silent = true })
vim.keymap.set("x", "<C-x>", require("dial.map").dec_visual(), { silent = true })
vim.keymap.set("x", "g<C-a>", require("dial.map").inc_gvisual(), { silent = true })
vim.keymap.set("x", "g<C-x>", require("dial.map").dec_gvisual(), { silent = true })

local augend = require("dial.augend")
require("dial.config").augends:register_group {
    default = {
        augend.constant.alias.Alpha,
        augend.constant.alias.alpha,

        augend.constant.alias.bool,
        augend.constant.new {
            elements = { "True", "False" },
            word = true,
            cyclic = true,
        },

        augend.constant.new {
            elements = { "and", "or" },
            word = true,
            cyclic = true,
        },
        augend.constant.new {
            elements = { "&&", "||" },
            word = false,
            cyclic = true,
        },

        augend.date.alias["%Y/%m/%d"],
        augend.date.alias["%-m/%-d"],
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%Y年%-m月%-d日"],
        augend.date.new {
            pattern = "%Y/%-m/%-d",
            default_kind = "day",
            only_valid = true,
            word = false,
        },

        augend.date.alias["%H:%M:%S"],
        augend.date.alias["%H:%M"],

        augend.integer.alias.binary,
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.integer.alias.octal,

        augend.semver.alias.semver,
    },
}
