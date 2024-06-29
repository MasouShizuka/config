local buftype = require("utils.buftype")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local treesitter = require("utils.treesitter")
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
        "folke/noice.nvim",
        cmd = {
            "Noice",
        },
        enabled = not environment.is_vscode,
        event = {
            "CmdlineEnter",
            "LspAttach",
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            messages = {
                view_search = false, -- view for search count messages. Set to `false` to disable
            },
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always "notify" and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = false,
            },
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
            },
            -- you can enable a preset for easier configuration
            presets = {
                command_palette = true, -- position the cmdline and popupmenu together
                lsp_doc_border = true,  -- add a border to hover docs and signature help
            },
            views = {
                mini = {
                    win_options = {
                        winblend = 0,
                    },
                },
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        kind = "",
                        find = "written",
                    },
                    opts = { skip = true },
                },
            },
        },
    },

    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not environment.is_vscode,
        ft = treesitter.treesitter_filetype_list,
        keys = {
            { "zR", function() require("ufo").openAllFolds() end,               desc = "Open all folds",          mode = "n" },
            { "zM", function() require("ufo").closeAllFolds() end,              desc = "Close all folds",         mode = "n" },
            { "zr", function() require("ufo").openFoldsExceptKinds() end,       desc = "Open folds except kinds", mode = "n" },
            { "zm", function() require("ufo").closeFoldsWith() end,             desc = "Close folds with",        mode = "n" },
            { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold",               mode = "n" },
        },
        opts = {
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
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
            end,
            preview = {
                win_config = {
                    winblend = 0,
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
            vim.list_extend(longfile_features, bigfile_features)

            vim.api.nvim_create_autocmd("BufReadPost", {
                callback = function(args)
                    local buf = args.buf

                    local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
                    if vim.tbl_contains(buftype.skip_buftype_list, bt) then
                        return
                    end

                    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    if vim.tbl_contains(filetype.skip_filetype_list, ft) then
                        return
                    end

                    if vim.b[buf].bigfile_detected and vim.b[buf].bigfile_detected == 1 then
                        return
                    end

                    if vim.b[buf].longfile_detected then
                        return
                    end

                    if not utils.is_longfile(buf) then
                        vim.b[buf].longfile_detected = 0
                        return
                    end

                    vim.notify("Long file detected!", vim.log.levels.WARN, { title = "bigfile" })

                    vim.b[buf].bigfile_detected = 1
                    vim.b[buf].longfile_detected = 1

                    local matched_features = vim.tbl_map(function(feature)
                        return require("bigfile.features").get_feature(feature)
                    end, longfile_features)

                    local matched_deferred_features = {}
                    for _, feature in ipairs(matched_features) do
                        feature.disable(buf)
                        if feature.opts.defer then
                            matched_deferred_features[#matched_deferred_features + 1] = feature
                        end
                    end

                    vim.api.nvim_create_autocmd("BufReadPost", {
                        buffer = buf,
                        callback = function()
                            for _, feature in ipairs(matched_deferred_features) do
                                feature.disable(buf)
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
        config = function(_, opts)
            require("notify").setup(opts)

            if utils.is_available("noice.nvim") and not package.loaded["noice"] then
                require("noice")
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
