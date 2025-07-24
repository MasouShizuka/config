local environment = require("utils.environment")

return {
    -- NOTE: 需要安装 ripgrep
    {
        "MagicDuck/grug-far.nvim",
        cmd = {
            "GrugFar",
            "GrugFarWithin",
        },
        config = function(_, opts)
            local grug_far = require("grug-far")
            grug_far.setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local utils = require("utils")

                    if utils.is_available("which-key.nvim") then
                        require("which-key").add({
                            { "<leader>t", buffer = args.buf, group = "Grug Far: toggle", mode = "n" },
                        })
                    end

                    vim.keymap.set("n", "<leader>tc", function()
                        local grug_far_prev_file = vim.g.grug_far_prev_file or ""

                        local FILTER_LINE_NO = 6
                        local filter_line = vim.fn.getline(FILTER_LINE_NO)
                        if #filter_line == 0 then
                            filter_line = grug_far_prev_file
                        else
                            filter_line = ""
                        end

                        vim.fn.setline(FILTER_LINE_NO, filter_line)
                        vim.notify("toggled current file only " .. utils.bool2str(filter_line ~= ""), vim.log.levels.INFO, { title = "Grug Far" })
                    end, { buffer = args.buf, desc = "Grug Far: toggle current file only", silent = true })
                    vim.keymap.set("n", "<leader>tf", function()
                        local state = unpack(require("grug-far").get_instance(0):toggle_flags({ "--fixed-strings" }))
                        vim.notify("toggled --fixed-strings " .. utils.bool2str(state), vim.log.levels.INFO, { title = "Grug Far" })
                    end, { buffer = args.buf, desc = "Grug Far: toggle --fixed-strings", silent = true })
                    vim.keymap.set("n", "<leader>tm", function()
                        local state = unpack(require("grug-far").get_instance(0):toggle_flags({ "--multiline" }))
                        vim.notify("toggled --multiline " .. utils.bool2str(state), vim.log.levels.INFO, { title = "Grug Far" })
                    end, { buffer = args.buf, desc = "Grug Far: toggle --multiline", silent = true })
                    vim.keymap.set("n", "<leader>te", function()
                        local state = unpack(require("grug-far").get_instance(0):toggle_flags({ "--replace=" }))
                        vim.notify("toggled empty string " .. utils.bool2str(state), vim.log.levels.INFO, { title = "Grug Far" })
                    end, { buffer = args.buf, desc = "Grug Far: toggle empty string", silent = true })
                end,
                group = vim.api.nvim_create_augroup("my-grug-far-custom-keybinds", { clear = true }),
                pattern = "grug-far",
            })
        end,
        enabled = not environment.is_vscode,
        keys = {
            {
                "<leader><c-f>",
                function()
                    vim.g.grug_far_prev_file = vim.fn.expand("%:p:."):gsub("\\", "/")
                    require("grug-far").open()
                end,
                desc = "Grug Far: open a grug-far buffer",
                mode = "n",
            },
            {
                "<leader><c-f>",
                function()
                    vim.g.grug_far_prev_file = vim.fn.expand("%:p:."):gsub("\\", "/")
                    require("grug-far").with_visual_selection()
                end,
                desc = "Grug Far: pre-fill current visual selection",
                mode = "x",
            },
        },
        opts = {
            -- search and replace engines configuration
            engines = {
                -- see https://github.com/BurntSushi/ripgrep
                ripgrep = {
                    -- extra args that you always want to pass
                    -- like for example if you always want context lines around matches
                    extraArgs = "--hidden --no-ignore",
                },
            },

            -- whether to start in insert mode,
            -- set to false for normal mode
            startInInsertMode = false,

            -- shortcuts for the actions you see at the top of the buffer
            -- set to '' or false to unset. Mappings with no normal mode value will be removed from the help header
            -- you can specify either a string which is then used as the mapping for both normal and insert mode
            -- or you can specify a table of the form { [mode] = <lhs> } (e.g. { i = '<C-enter>', n = '<localleader>gr'})
            -- it is recommended to use <localleader> though as that is more vim-ish
            -- see https://learnvimscriptthehardway.stevelosh.com/chapters/11.html#local-leader
            keymaps = {
                -- replace = { n = "<localleader>r" },
                replace = { n = "R" },
                -- qflist = { n = "<localleader>q" },
                -- syncLocations = { n = "<localleader>s" },
                -- syncLine = { n = "<localleader>l" },
                syncLine = { n = "r" },
                -- close = { n = "<localleader>c" },
                close = { n = "<c-w>" },
                -- historyOpen = { n = "<localleader>t" },
                historyOpen = { n = "<leader>h" },
                -- historyAdd = { n = "<localleader>a" },
                -- refresh = { n = "<localleader>f" },
                -- openNextLocation = { n = "<down>" },
                -- openPrevLocation = { n = "<up>" },
                -- gotoLocation = { n = "<enter>" },
                -- pickHistoryEntry = { n = "<enter>" },
                -- abort = { n = "<localleader>b" },
                -- help = { n = "g?" },
                -- toggleShowCommand = { n = "<localleader>p" },
                -- swapEngine = { n = "<localleader>e" },
                -- previewLocation = { n = "<localleader>i" },
                -- swapReplacementInterpreter = { n = "<localleader>x" },
                -- applyNext = { n = "<localleader>j" },
                -- applyPrev = { n = "<localleader>k" },
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
