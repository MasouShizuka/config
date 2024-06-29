local utils = require("utils")

return {
    {
        "asiryk/auto-hlsearch.nvim",
        cmd = {
            "AutoHlsearch",
            "AutoHlsearchDisable",
            "AutoHlsearchEnable",
            "AutoHlsearchToggle",
        },
        keys = {
            { "/", desc = "Search forward",  mode = { "n", "x" } },
            { "?", desc = "Search backward", mode = { "n", "x" } },
            { "*", desc = "Next",            mode = { "n", "x" } },
            { "#", desc = "Previous",        mode = { "n", "x" } },
            { "n", desc = "Next",            mode = { "n", "x" } },
            { "N", desc = "Previous",        mode = { "n", "x" } },
        },
        opts = {
            remap_keys = { "/", "?", "*", "#", "n", "N" },
            create_commands = true,
            pre_hook = function() end,
            post_hook = function()
                if utils.is_available("mini.map") then
                    require("mini.map").refresh()
                end
            end,
        },
    },
}
