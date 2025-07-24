local environment = require("utils.environment")

return {
    {
        "rebelot/heirline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        event = {
            "UIEnter",
        },
        opts = function()
            local bhu = require("plugins.bars_and_lines.heirline.utils")
            local utils = require("utils")

            local herrline_conditions = require("heirline.conditions")
            local heirline_utils = require("heirline.utils")


            bhu.load_colors()


            local git_flexible = { flexible = 2 }

            local git_branch = require("plugins.bars_and_lines.heirline.git").git_branch
            local git_status = require("plugins.bars_and_lines.heirline.git").git_status

            git_flexible = bhu.insert_with_child_condition(
                git_flexible,
                bhu.insert_with_child_condition({}, git_branch, git_status),
                git_status
            )


            local lsp_flexible = { flexible = 1 }

            local lsp_info = { condition = herrline_conditions.lsp_attached }
            if utils.is_available("venv-selector.nvim") then
                local python_venv = require("plugins.bars_and_lines.heirline.lsp").python_venv
                lsp_info = heirline_utils.insert(lsp_info, bhu.padding_after(python_venv))
            end
            lsp_info = heirline_utils.insert(lsp_info, require("plugins.bars_and_lines.heirline.lsp").lsp_server)

            local diagnostic = require("plugins.bars_and_lines.heirline.diagnostic").diagnostic

            if utils.is_available("nvim-lint") then
                lsp_flexible = bhu.insert_with_child_condition(
                    lsp_flexible,
                    bhu.insert_with_child_condition(
                        {},
                        lsp_info,
                        bhu.padding_before(require("plugins.bars_and_lines.heirline.lint")),
                        diagnostic
                    )
                )
            end

            lsp_flexible = bhu.insert_with_child_condition(
                lsp_flexible,
                bhu.insert_with_child_condition({}, lsp_info, diagnostic),
                diagnostic
            )


            local align = bhu.align
            local mode = require("plugins.bars_and_lines.heirline.mode")
            local file_size = require("plugins.bars_and_lines.heirline.file").file_size
            local search_count = require("plugins.bars_and_lines.heirline.cmd").search_count
            local macro = require("plugins.bars_and_lines.heirline.cmd").macro
            local show_cmd = require("plugins.bars_and_lines.heirline.cmd").show_cmd
            local lazy = require("plugins.bars_and_lines.heirline.lazy")
            local ruler = require("plugins.bars_and_lines.heirline.nav").ruler
            local scrollbar = require("plugins.bars_and_lines.heirline.nav").scrollbar


            local default_statusline = {}
            for _, value in ipairs({
                { component = bhu.padding_after(mode, 2) },
                { component = bhu.padding_after(git_flexible, 2) },
                { component = bhu.padding_after(lsp_flexible, 2) },
                { component = bhu.padding_after(require("plugins.bars_and_lines.heirline.conform"), 2),           package = "conform.nvim" },
                { component = bhu.padding_after(require("plugins.bars_and_lines.heirline.dap"), 2),               package = "nvim-dap" },
                { component = bhu.padding_after(require("plugins.bars_and_lines.heirline.overseer"), 1),          package = "overseer.nvim" },
                { component = bhu.padding_after(file_size, 2) },
                { component = bhu.padding_after(search_count, 2) },
                { component = bhu.padding_after(macro, 2) },
                { component = bhu.padding_after(show_cmd, 2) },
                { component = align },
                { component = bhu.padding_after(lazy, 2) },
                { component = bhu.padding_after(require("plugins.bars_and_lines.heirline.file").file_indent, 2) },
                { component = bhu.padding_after(require("plugins.bars_and_lines.heirline.file").file_encoding, 2) },
                { component = bhu.padding_after(require("plugins.bars_and_lines.heirline.file").file_format, 2) },
                { component = bhu.padding_after(ruler, 2) },
                { component = bhu.padding_after(scrollbar, 2) },
            }) do
                if value.package == nil or utils.is_available(value.package) then
                    default_statusline[#default_statusline + 1] = value.component
                end
            end


            local winbar = {}
            if utils.is_available("nvim-navic") then
                winbar[#winbar + 1] = require("plugins.bars_and_lines.heirline.navic")
            end
            if #winbar == 0 then
                winbar = nil
            end

            return {
                statusline = {
                    hl = {
                        bg = require("utils.colors").colors.black,
                        fg = require("utils.colors").colors.white,
                    },
                    fallthrough = false,

                    {
                        condition = function()
                            return herrline_conditions.buffer_matches({ buftype = { "terminal" } })
                        end,

                        bhu.padding_after(mode, 2),
                        align,
                    },
                    {
                        condition = function()
                            return herrline_conditions.buffer_matches({
                                buftype = require("utils.buftype").skip_buftype_list,
                                filetype = require("utils.filetype").skip_filetype_list,
                            })
                        end,

                        bhu.padding_after(mode, 2),
                        bhu.padding_after(file_size, 2),
                        bhu.padding_after(search_count, 2),
                        bhu.padding_after(show_cmd, 2),
                        align,
                        bhu.padding_after(lazy, 2),
                        bhu.padding_after(ruler, 2),
                        bhu.padding_after(scrollbar, 2),
                    },
                    default_statusline,
                },
                winbar = winbar,
                tabline = {
                    require("plugins.bars_and_lines.heirline.tabline").tabline_offset,
                    require("plugins.bars_and_lines.heirline.tabline").tablist,
                },
                statuscolumn = {
                    require("plugins.bars_and_lines.heirline.statuscolumn").foldcolumn,
                    require("plugins.bars_and_lines.heirline.statuscolumn").signcolumn,
                    align,
                    require("plugins.bars_and_lines.heirline.statuscolumn").numbercolumn,
                },
                opts = {
                    disable_winbar_cb = function(args)
                        local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                        return not vim.tbl_contains(require("utils.lsp").lsp_filetype_list, ft)
                    end,
                },
            }
        end,
    },

    {
        "SmiteshP/nvim-navic",
        enabled = not environment.is_vscode and environment.lsp_enable,
        event = {
            "LspAttach",
        },
        opts = function()
            return {
                icons = require("utils.icons").kinds,
                lazy_update_content = true,
                lsp = {
                    auto_attach = true,
                    preference = require("utils.lsp").lsp_list,
                },
            }
        end,
    },
}
