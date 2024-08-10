local environment = require("utils.environment")

return {
    -- NOTE: 需要安装 ripgrep
    {
        "MagicDuck/grug-far.nvim",
        cmd = {
            "GrugFar",
        },
        enabled = not environment.is_vscode,
        keys = {
            { "<leader><c-f>", function() require("grug-far").grug_far() end,              desc = "Grug Far: open a grug-far buffer",            mode = "n" },
            { "<leader><c-f>", function() require("grug-far").with_visual_selection() end, desc = "Grug Far: pre-fill current visual selection", mode = "x" },
        },
        opts = {
            -- whether to start in insert mode,
            -- set to false for normal mode
            startInInsertMode = false,

            -- shortcuts for the actions you see at the top of the buffer
            -- set to '' or false to unset. Mappings with no normal mode value will be removed from the help header
            -- you can specify either a string which is then used as the mapping for both normmal and insert mode
            -- or you can specify a table of the form { [mode] = <lhs> } (ex: { i = '<C-enter>', n = '<localleader>gr'})
            -- it is recommended to use <localleader> though as that is more vim-ish
            -- see https://learnvimscriptthehardway.stevelosh.com/chapters/11.html#local-leader
            keymaps = {
                replace = { n = "<leader>r" },
                qflist = { n = "<leader>q" },
                syncLocations = { n = "R" },
                syncLine = { n = "r" },
                close = { n = "<c-w>" },
                historyOpen = { n = "<leader>o" },
                historyAdd = { n = "<leader>a" },
                refresh = { n = "<leader>f" },
                gotoLocation = { n = "<enter>" },
                pickHistoryEntry = { n = "<enter>" },
                abort = { n = "<leader>b" },
            },

            -- search history settings
            history = {
                -- configuration for when to auto-save history entries
                autoSave = {
                    -- whether to auto-save at all, trumps all other settings below
                    enabled = false,

                    -- auto-save after buffer is deleted
                    onBufDelete = false,
                },
            },
        },
    },
}
