return {
    "monaqa/dial.nvim",
    config = function()
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
    end,
    keys = {
        { "<C-a>",  function() return require("dial.map").inc_normal() end,  expr = true, mode = "n" },
        { "<C-x>",  function() return require("dial.map").dec_normal() end,  expr = true, mode = "n" },
        { "<C-a>",  function() return require("dial.map").inc_visual() end,  expr = true, mode = "x" },
        { "<C-x>",  function() return require("dial.map").dec_visual() end,  expr = true, mode = "x" },
        { "g<C-a>", function() return require("dial.map").inc_gvisual() end, expr = true, mode = "x" },
        { "g<C-x>", function() return require("dial.map").dec_gvisual() end, expr = true, mode = "x" },
    },
}
