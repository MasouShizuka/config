local variables = require("config.variables")

return {
    {
        "Aasim-A/scrollEOF.nvim",
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        opts = {
            -- The pattern used for the internal autocmd to determine
            -- where to run scrollEOF. See https://neovim.io/doc/user/autocmd.html#autocmd-pattern
            pattern = "*",
            -- Whether or not scrollEOF should be enabled in insert mode
            insert_mode = false,
            -- List of filetypes to disable scrollEOF for.
            disabled_filetypes = {},
            -- List of modes to disable scrollEOF for. see https://neovim.io/doc/user/builtin.html#mode() for available modes.
            disabled_modes = {},
        },
    },

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
            { variables.keymap["<c-s-t>"],               desc = "Undo quit",     mode = "n" },
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

            -- 启用 resession 时取消注释
            -- https://github.com/kevinhwang91/nvim-ufo/issues/57
            -- Folds close automatically when leaving insert mode by pressing <esc>
            -- vim.api.nvim_create_autocmd("BufEnter", {
            --     callback = function()
            --         vim.api.nvim_set_option_value("foldlevel", 99, { scope = "local" })
            --     end,
            --     desc = "Set foldlevel=99 when enter buffer",
            --     group = vim.api.nvim_create_augroup("nvim-ufo", { clear = true }),
            --     pattern = "*",
            -- })

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
                            { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
                            { text = { "%s" },                  click = "v:lua.ScSa" },
                            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                        },
                    })
                end,
            },
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not variables.is_vscode and not variables.is_wsl,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        keys = {
            { "zR", function(...) require("ufo").openAllFolds(...) end,         desc = "Open all folds",          mode = "n" },
            { "zM", function(...) require("ufo").closeAllFolds(...) end,        desc = "Close all folds",         mode = "n" },
            { "zr", function(...) require("ufo").openFoldsExceptKinds(...) end, desc = "Open folds except kinds", mode = "n" },
            { "zm", function(...) require("ufo").closeFoldsWith(...) end,       desc = "Close folds with",        mode = "n" },
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

            -- vim.notify = require("notify")
            vim.notify = function(message, ...)
                if message:match("warning: multiple different client offset_encodings detected for buffer, this is not supported yet") then
                    return
                end

                require("notify")(message, ...)
            end
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
