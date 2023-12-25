local buftype = require("utils.buftype")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local icons = require("utils.icons")
local utils = require("utils")

return {
    {
        "Aasim-A/scrollEOF.nvim",
        enabled = not environment.is_vscode,
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
                foldclose = icons.fold.FoldClosed,
                foldopen = icons.fold.FoldOpened,
                foldsep = icons.fold.FoldSeparator,
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
        enabled = not environment.is_vscode,
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
        enabled = not environment.is_vscode,
        event = {
            "User BigFile",
        },
        init = function()
            vim.api.nvim_create_autocmd("BufReadPre", {
                callback = function(args)
                    local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
                    if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                        return
                    end

                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if vim.tbl_contains(filetype.skip_filetype_list, ft) then
                        return
                    end

                    if utils.is_bigfile(args.buf) then
                        utils.event("BigFile")
                        vim.api.nvim_del_augroup_by_name("BigFile")

                        vim.api.nvim_create_autocmd("BufReadPost", {
                            buffer = args.buf,
                            callback = function()
                                utils.refresh_current_buf(1, true)
                            end,
                            desc = "Big file",
                            group = vim.api.nvim_create_augroup("BigFileRefresh", { clear = true }),
                            once = true,
                        })
                    end
                end,
                desc = "Big file",
                group = vim.api.nvim_create_augroup("BigFile", { clear = true }),
            })

            local bigfile_features = {
                "syntax",
                "matchparen",
                "vimopts",
                "filetype",
            }
            if utils.is_available("indent-blankline.nvim") then
                bigfile_features[#bigfile_features + 1] = "indent_blankline"
            end
            if utils.is_available("vim-illuminate") then
                bigfile_features[#bigfile_features + 1] = "illuminate"
            end
            if utils.is_available("nvim-lspconfig") then
                bigfile_features[#bigfile_features + 1] = "lsp"
            end
            if utils.is_available("nvim-treesitter") then
                bigfile_features[#bigfile_features + 1] = "treesitter"
            end

            vim.g.bigfile_features = bigfile_features

            local longfile_features = {
                {
                    name = "wrap",
                    opts = {
                        defer = false,
                    },
                    disable = function()
                        vim.api.nvim_set_option_value("wrap", false, { scope = "local" })
                    end,
                },
            }

            vim.api.nvim_create_autocmd("BufReadPost", {
                callback = function(args)
                    local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
                    if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                        return
                    end

                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if vim.tbl_contains(filetype.skip_filetype_list, ft) then
                        return
                    end

                    local status_ok, _ = pcall(vim.api.nvim_buf_get_var, args.buf, "bigfile_detected")
                    if status_ok then
                        return
                    end

                    if not utils.is_longfile(args.buf) then
                        vim.api.nvim_buf_set_var(args.buf, "bigfile_detected", 0)
                        return
                    end

                    vim.notify("Long file detected!", vim.log.levels.WARN, { title = "bigfile" })

                    vim.api.nvim_buf_set_var(args.buf, "bigfile_detected", 1)

                    local features = bigfile_features
                    for _, feature in ipairs(longfile_features) do
                        features[#features + 1] = feature
                    end

                    local matched_features = vim.tbl_map(function(feature)
                        return require("bigfile.features").get_feature(feature)
                    end, features)

                    local matched_deferred_features = {}
                    for _, feature in ipairs(matched_features) do
                        feature.disable(args.buf)
                        if feature.opts.defer then
                            table.insert(matched_deferred_features, feature)
                        end
                    end

                    vim.api.nvim_create_autocmd("BufReadPost", {
                        buffer = args.buf,
                        callback = function()
                            for _, feature in ipairs(matched_deferred_features) do
                                feature.disable(args.buf)
                            end
                        end,
                    })
                end,
                desc = "Long file",
                group = vim.api.nvim_create_augroup("LongFile", { clear = true }),
            })
        end,
        opts = function()
            return {
                -- 禁用 filesize 检查，只通过 pattern 判断
                filesize = math.huge,
                pattern = function(bufnr, filesize_mib)
                    local bt = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
                    if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                        return false
                    end

                    local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
                    if vim.tbl_contains(filetype.skip_filetype_list, ft) then
                        return false
                    end

                    if utils.is_bigfile(bufnr) then
                        vim.notify("Big file detected!", vim.log.levels.WARN, { title = "bigfile" })
                        return true
                    end

                    return false
                end,
                features = vim.g.bigfile_features,
            }
        end,
    },

    {
        "mbbill/fencview",
        cmd = {
            "FencAutoDetect",
            "FencView",
        },
        enabled = not environment.is_vscode,
    },

    {
        "rcarriga/nvim-notify",
        init = function()
            vim.notify = function(message, ...)
                require("notify")(message, ...)
            end
        end,
        enabled = not environment.is_vscode,
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
        enabled = not environment.is_vscode,
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
