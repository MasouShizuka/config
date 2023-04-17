return {
    "gbprod/substitute.nvim",
    keys = {
        { "gr",  function() require("substitute").operator() end,          mode = "n" },
        { "grr", function() require("substitute").line() end,              mode = "n" },
        { "R",   function() require("substitute").visual() end,            mode = "x" },
        { "cx",  function() require("substitute.exchange").operator() end, mode = "n" },
        { "cxx", function() require("substitute.exchange").line() end,     mode = "n" },
        { "C",   function() require("substitute.exchange").visual() end,   mode = "x" },
        { "cxc", function() require("substitute.exchange").cancel() end,   mode = "n" },
    },
    opts = {
        on_substitute = nil,
        yank_substituted_text = false,
        highlight_substituted_text = {
            enabled = true,
            timer = 500,
        },
        range = {
            prefix = "s",
            prompt_current_text = false,
            confirm = false,
            complete_word = false,
            motion1 = false,
            motion2 = false,
            suffix = "",
        },
        exchange = {
            motion = false,
            use_esc_to_cancel = true,
        },
    },
}
