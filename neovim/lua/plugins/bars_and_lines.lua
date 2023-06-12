local variables = require("config.variables")

return {
    {
        "akinsho/bufferline.nvim",
        cmd = {
            "BufferLinePick",
            "BufferLinePickClose",
            "BufferLineCycleNext",
            "BufferLineCyclePrev",
            "BufferLineCloseRight",
            "BufferLineCloseLeft",
            "BufferLineMoveNext",
            "BufferLineMovePrev",
            "BufferLineSortByExtension",
            "BufferLineSortByDirectory",
            "BufferLineSortByRelativeDirectory",
            "BufferLineSortByTabs",
            "BufferLineGoToBuffer",
            "BufferLineTogglePin",
            "BufferLineGroupClose",
            "BufferLineGroupToggle",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        event = {
            "UIEnter",
        },
        keys = {
            { "<c-h>", function() vim.api.nvim_command("BufferLineCyclePrev") end, desc = "Cycle previous tab", mode = "n" },
            { "<c-l>", function() vim.api.nvim_command("BufferLineCycleNext") end, desc = "Cycle next tab",     mode = "n" },
        },
        opts = {
            options = {
                -- mode = "buffers", -- set to "tabs" to only show tabpages instead
                mode = "tabs",
                -- numbers = "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
                numbers = "ordinal",
                indicator = {
                    -- style = "icon" | "underline" | "none",
                    style = "none",
                },
                -- diagnostics = false | "nvim_lsp" | "coc",
                diagnostics = "nvim_lsp",
                -- offsets = {
                --     {
                --         filetype = "NvimTree",
                --         text = "File Explorer" | function ,
                --         text_align = "left" | "center" | "right"
                --         separator = true
                --     }
                -- },
                -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local icons = variables.icons.diagnostics
                    local ret = (diagnostics_dict.error and icons.Error .. diagnostics_dict.error .. " " or "")
                        .. (diagnostics_dict.warning and icons.Warn .. diagnostics_dict.warning or "")
                    return vim.trim(ret)
                end,
                offsets = {
                    {
                        filetype = "NvimTree",
                        highlight = "Directory",
                        text = function()
                            return vim.fn.getcwd()
                        end,
                        text_align = "center",
                    },
                },
                -- -- can also be a table containing 2 custom separators
                -- -- [focused and unfocused]. eg: { '|', '|' }
                -- separator_style = "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
                separator_style = { "|", "|" },
                -- sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
                --     -- add custom logic
                --     return buffer_a.modified > buffer_b.modified
                -- end
                sort_by = "tabs",
            },
        },
        version = "v3.*",
    },

    {
        "Bekaboo/dropbar.nvim",
        enabled = not variables.is_vscode,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader><tab>", function() require("dropbar.api").pick() end, desc = "Pick mode", mode = "n" },
        },
        lazy = false,
        opts = {
            icons = {
                kinds = {
                    symbols = variables.icons.kinds,
                },
            },
            menu = {
                entry = {
                    padding = {
                        left = 0,
                        right = 0,
                    },
                },
                keymaps = {
                    ["h"] = "<cmd>q!<cr><esc>",
                    ["l"] = function()
                        local menu = require("dropbar.api").get_current_dropbar_menu()
                        if not menu then
                            return
                        end
                        vim.cmd.normal("w")
                        local cursor = vim.api.nvim_win_get_cursor(menu.win)
                        local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
                        if component then
                            menu:click_on(component, nil, 1, "l")
                        end
                    end,
                    ["o"] = function()
                        local menu = require("dropbar.api").get_current_dropbar_menu()
                        if not menu then
                            return
                        end
                        vim.cmd.normal("0")
                        local cursor = vim.api.nvim_win_get_cursor(menu.win)
                        local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
                        if component then
                            menu:click_on(component, nil, 1, "l")
                        end
                    end,
                },
            },
        },
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        opts = {
            options = {
                section_separators = { left = "", right = "" },
                component_separators = { left = "|", right = "|" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", {
                    "diff",
                    symbols = variables.icons.git,
                }, {
                    "diagnostics",
                    symbols = {
                        error = variables.icons.diagnostics.Error,
                        hint = variables.icons.diagnostics.Hint,
                        info = variables.icons.diagnostics.Info,
                        warn = variables.icons.diagnostics.Warn,
                    },
                }, },
                lualine_c = { "filename", "filesize" },
                lualine_x = {
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    "encoding",
                    "fileformat",
                    "filetype",
                },
            },
            inactive_sections = {
                lualine_c = { "filename", "filesize" },
            },
        },
        event = {
            "UIEnter",
        },
    },

    {
        "RRethy/vim-illuminate",
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        keys = {
            { "<f7>",   function() require("illuminate").goto_next_reference(false) end, desc = "Go to next reference",     mode = "n" },
            { "<s-f7>", function() require("illuminate").goto_prev_reference(false) end, desc = "Go to previous reference", mode = "n" },
        },
    },
}
