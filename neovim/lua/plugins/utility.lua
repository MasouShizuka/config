local utils = require("config.utils")
local variables = require("config.variables")

return {
    {
        "Aasim-A/scrollEOF.nvim",
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
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
        "kevinhwang91/nvim-ufo",
        config = function(_, opts)
            vim.opt.fillchars:append({
                eob = " ",
                fold = " ",
                foldclose = variables.icons.fold.FoldClosed,
                foldopen = variables.icons.fold.FoldOpened,
                foldsep = variables.icons.fold.FoldSeparator,
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
            -- })

            local handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "MoreMsg" })
                return newVirtText
            end
            opts["fold_virt_text_handler"] = handler

            require("ufo").setup(opts)
        end,
        dependencies = {
            "kevinhwang91/promise-async",
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not variables.is_vscode,
        event = {
            "User TreesitterFile",
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
        "LunarVim/bigfile.nvim",
        event = {
            "User BigFile",
        },
        init = function()
            vim.api.nvim_create_autocmd("BufReadPre", {
                callback = function(args)
                    if utils.is_bigfile(args.buf) then
                        utils.event("BigFile")
                        vim.api.nvim_del_augroup_by_name("BigFile")
                        utils.refresh_current_buf(10)
                    end
                end,
                desc = "Big file",
                group = vim.api.nvim_create_augroup("BigFile", { clear = true }),
            })
        end,
        opts = {
            -- 禁用 filesize 检查，只通过 pattern 判断
            filesize = 1e10,
            pattern = function(bufnr, filesize_mib)
                local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
                if vim.tbl_contains(variables.skip_buftype_list, buftype) then
                    return false
                end

                local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
                if vim.tbl_contains(variables.skip_filetype_list, filetype) then
                    return false
                end

                if utils.is_bigfile(bufnr) then
                    vim.notify("Big file detected!", vim.log.levels.WARN, { title = "bigfile" })
                    return true
                end

                return false
            end,
            features = {
                "indent_blankline",
                -- "illuminate",
                "lsp",
                "treesitter",
                "syntax",
                "matchparen",
                "vimopts",
                "filetype",
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
        init = function()
            vim.notify = function(message, ...)
                if message == "warning: multiple different client offset_encodings detected for buffer, this is not supported yet" then
                    return
                end

                require("notify")(message, ...)
            end
        end,
        enabled = not variables.is_vscode,
        lazy = true,
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
        init = function()
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
        lazy = true,
        opts = {},
    },

    {
        "tzachar/highlight-undo.nvim",
        keys = {
            { "u",     desc = "Undo", mode = "n" },
            { "<c-r>", desc = "Redo", mode = "n" },
        },
        opts = {
            duration = 1000,
        },
    },
}
