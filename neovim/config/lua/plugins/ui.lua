local environment = require("utils.environment")

return {
    {
        "folke/noice.nvim",
        cmd = {
            "Noice",
        },
        cond = not environment.is_vscode,
        event = {
            "CmdlineEnter",
            "LspAttach",
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
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
                override = {
                    -- override the default lsp markdown formatter with Noice
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    -- override cmp documentation with Noice (needs the other options to work)
                    ["cmp.entry.get_documentation"] = true,
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
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                        },
                    },
                    view = "mini",
                },
            },
        },
    },

    {
        "xieyonn/spinner.nvim",
        cmd = {
            "Spinner",
        },
        cond = not environment.is_vscode,
        lazy = true,
        opts = {},
    },
}
