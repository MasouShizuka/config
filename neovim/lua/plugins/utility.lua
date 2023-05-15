local variables = require("config.variables")

return {
    {
        "AndrewRadev/undoquit.vim",
        enabled = not variables.is_vscode,
        event = {
            "BufEnter",
        },
        init = function()
            vim.g.undoquit_mapping = variables.keymap["<c-s-t>"]
            vim.g.undoquit_tab_mapping = "<leader>" .. variables.keymap["<c-s-t>"]
        end,
        keys = {
            { variables.keymap["<c-s-t>"], desc = "Undo quit", mode = "n" },
            { "<leader>" .. variables.keymap["<c-s-t>"], desc = "Undo quit tab", mode = "n" },
        },
    },

    {
        "kevinhwang91/nvim-ufo",
        config = function(_, opts)
            vim.opt.fillchars:append({
                eob = " ",
                fold = " ",
                foldopen = "",
                foldsep = " ",
                foldclose = "",
            })
            vim.opt.foldcolumn = "1"
            vim.opt.foldenable = true
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99

            require("ufo").setup(opts)
        end,
        dependencies = {
            "kevinhwang91/promise-async",
            {
                "luukvbaal/statuscol.nvim",
                config = function(_, opts)
                    local builtin = require("statuscol.builtin")
                    require("statuscol").setup({
                        segments = {
                            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                            { text = { "%s" }, click = "v:lua.ScSa" },
                            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                        },
                    })
                end,
            },
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        keys = {
            {
                "zR",
                function(...)
                    require("ufo").openAllFolds(...)
                end,
                desc = "Open all folds",
                mode = "n",
            },
            {
                "zM",
                function(...)
                    require("ufo").closeAllFolds(...)
                end,
                desc = "Close all folds",
                mode = "n",
            },
            {
                "zr",
                function(...)
                    require("ufo").openFoldsExceptKinds(...)
                end,
                desc = "Open folds except kinds",
                mode = "n",
            },
            {
                "zm",
                function(...)
                    require("ufo").closeFoldsWith(...)
                end,
                desc = "Close folds with",
                mode = "n",
            },
            {
                "K",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then
                        vim.lsp.buf.hover()
                    end
                end,
                desc = "Hover",
                mode = "n",
            },
        },
        opts = {
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
            preview = {
                win_config = {
                    border = "rounded",
                    winblend = 0,
                    winhighlight = "Normal:Normal",
                    maxheight = 20,
                },
                mappings = {
                    scrollB = "",
                    scrollF = "",
                    scrollU = "<c-u>",
                    scrollD = "<c-d>",
                    scrollE = "<c-e>",
                    scrollY = "<c-y>",
                    jumpTop = "",
                    jumpBot = "",
                    close = "q",
                    switch = "<tab>",
                    trace = "<cr>",
                },
            },
        },
    },

    {
        "mbbill/fencview",
        cmd = {
            "FencAutoDetect",
            "FencView",
        },
        enabled = not variables.is_vscode,
    },

    {
        "rcarriga/nvim-notify",
        config = function(_, opts)
            require("notify").setup(opts)

            vim.notify = require("notify")
        end,
        enabled = not variables.is_vscode,
        lazy = false,
        opts = {
            timeout = 3000,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            max_height = function()
                return math.floor((vim.o.lines - vim.o.cmdheight) * 0.75)
            end,
            background_colour = "#000000",
        },
    },

    {
        "stevearc/dressing.nvim",
        enabled = not variables.is_vscode,
        lazy = false,
        opts = {},
    },
}
