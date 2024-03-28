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
            -- List of filetypes to disable scrollEOF for.
            disabled_filetypes = filetype.skip_filetype_list,
        },
    },

    {
        "delphinus/cellwidths.nvim",
        cmd = {
            "CellWidthsAdd",
            "CellWidthsDelete",
            "CellWidthsLoad",
            "CellWidthsRemove",
        },
        enabled = not environment.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        opts = {
            name = "default",
            -- name = "empty",          -- 空の設定です。
            -- name = "default",        -- vim-ambiwidth のデフォルトです。
            -- name = "cica",           -- vim-ambiwidth の Cica 用設定です。
            -- name = "sfmono_square",  -- SF Mono Square 用設定です。
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
                        newVirtText[#newVirtText + 1] = chunk
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        newVirtText[#newVirtText + 1] = { chunkText, hlGroup }
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                newVirtText[#newVirtText + 1] = { suffix, "MoreMsg" }
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
        init = function()
            -- bigfile 自动激活
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
                        require("bigfile")
                        vim.api.nvim_del_augroup_by_name("BigFile")
                    end
                end,
                desc = "Big file event",
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

                    local bigfile_status, bigfile_detected = pcall(vim.api.nvim_buf_get_var, args.buf, "bigfile_detected")
                    if bigfile_status and bigfile_detected == 1 then
                        return
                    end

                    local longfile_status, _ = pcall(vim.api.nvim_buf_get_var, args.buf, "longfile_detected")
                    if longfile_status then
                        return
                    end

                    if not utils.is_longfile(args.buf) then
                        vim.api.nvim_buf_set_var(args.buf, "longfile_detected", 0)
                        return
                    end

                    vim.notify("Long file detected!", vim.log.levels.WARN, { title = "bigfile" })

                    vim.api.nvim_buf_set_var(args.buf, "bigfile_detected", 1)
                    vim.api.nvim_buf_set_var(args.buf, "longfile_detected", 1)

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
                            matched_deferred_features[#matched_deferred_features + 1] = feature
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
                desc = "Long file event",
                group = vim.api.nvim_create_augroup("LongFile", { clear = true }),
            })
        end,
        lazy = true,
        opts = function()
            return {
                -- 禁用 filesize 检查，只通过 pattern 判断
                filesize = math.huge,                   -- size of the file in MiB, the plugin round file sizes to the closest MiB
                pattern = function(bufnr, filesize_mib) -- autocmd pattern or function see <### Overriding the detection of big files>
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
                features = vim.g.bigfile_features, -- features to disable
            }
        end,
    },

    {
        "mbbill/fencview",
        cmd = {
            "FencAutoDetect",
            "FencView",
        },
        init = function()
            vim.api.nvim_create_user_command("FencAutoDetectWithoutEcho", function()
                vim.api.nvim_command("FencAutoDetect")
                vim.cmd.redraw()
            end, { desc = "Toggle wrap" })
        end,
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
        "Sam-programs/cmdline-hl.nvim",
        build = ":TSUpdate regex",
        event = {
            "CmdlineEnter",
        },
        enabled = not environment.is_vscode,
        opts = {
            -- custom prefixes for builtin-commands
            type_signs = {
                [":"] = { icons.surround.chevron_right .. " ", "Title" },
                ["/"] = { icons.misc.search .. icons.surround.angle_double_down .. " ", "Title" },
                ["?"] = { icons.misc.search .. icons.surround.angle_double_up .. " ", "Title" },
            },
            -- custom formatting/highlight for commands
            custom_types = {
                -- ["command-name"] = {
                -- [icon],[icon_hl], default to `:` icon and highlight
                -- [lang], defaults to vim
                -- [showcmd], defaults to false
                -- [pat], defaults to "%w*%s*(.*)"
                -- [code], defaults to nil
                -- }
                -- lang is the treesitter language to use for the commands
                -- showcmd is true if the command should be displayed or to only show the icon
                -- pat is used to extract the part of the command that needs highlighting
                -- the part is matched against the raw command you don't need to worry about ranges
                -- e.g. in '<,>'s/foo/bar/
                -- pat is checked against s/foo/bar
                -- you could also use the 'code' function to extract the part that needs highlighting
                ["="] = { pat = "=(.*)", icon = icons.misc.calculator .. " ", lang = "lua", show_cmd = false },
                ["help"] = { icon = icons.misc.question .. " " },
                ["lua"] = { icon = icons.languages.lua .. " ", lang = "lua" },
                ["substitute"] = { icon = icons.misc.replace_all .. " ", lang = "regex", show_cmd = true },
            },
        },
    },

    {
        "stevearc/dressing.nvim",
        enabled = not environment.is_vscode,
        init = function()
            vim.ui.select = function(...)
                require("dressing.select")(...)
            end

            vim.ui.input = function(...)
                require("dressing.input")(...)
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
