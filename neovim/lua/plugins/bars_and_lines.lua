local utils = require("config.utils")
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
        config = function(_, opts)
            require("bufferline").setup(opts)

            local purple = utils.get_highlight_color("purple", "fg")
            vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bold = true, fg = purple })
            vim.api.nvim_set_hl(0, "BufferLineNumbersSelected", { bold = true, fg = purple })
        end,
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
                -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local icons = variables.icons.diagnostics
                    local ret = (diagnostics_dict.error and icons.error .. diagnostics_dict.error .. " " or "")
                        .. (diagnostics_dict.warning and icons.warn .. diagnostics_dict.warning or "")
                    return vim.trim(ret)
                end,
                -- offsets = {
                --     {
                --         filetype = "NvimTree",
                --         text = "File Explorer" | function ,
                --         text_align = "left" | "center" | "right"
                --         separator = true
                --     }
                -- },
                offsets = {
                    {
                        filetype = "neo-tree",
                        highlight = "Directory",
                        text = function()
                            return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
                        end,
                        text_align = "center",
                    },
                    {
                        filetype = "NvimTree",
                        highlight = "Directory",
                        text = function()
                            return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
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

    -- 会使得 lsp 跳转到未打开的文件时卡死
    -- {
    --     "Bekaboo/dropbar.nvim",
    --     enabled = not variables.is_vscode,
    --     dependencies = {
    --         "nvim-tree/nvim-web-devicons",
    --     },
    --     keys = {
    --         { "<leader><tab>", function() require("dropbar.api").pick() end, desc = "Pick mode", mode = "n" },
    --     },
    --     lazy = false,
    --     opts = {
    --         icons = {
    --             kinds = {
    --                 symbols = variables.icons.kinds,
    --             },
    --         },
    --         menu = {
    --             entry = {
    --                 padding = {
    --                     left = 0,
    --                     right = 0,
    --                 },
    --             },
    --             keymaps = {
    --                 ["h"] = "<cmd>q!<cr><esc>",
    --                 ["q"] = "<cmd>q!<cr><esc>",
    --                 ["l"] = function()
    --                     local menu = require("dropbar.api").get_current_dropbar_menu()
    --                     if not menu then
    --                         return
    --                     end
    --                     vim.cmd.normal("w")
    --                     local cursor = vim.api.nvim_win_get_cursor(menu.win)
    --                     local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
    --                     if component then
    --                         menu:click_on(component, nil, 1, "l")
    --                     end
    --                 end,
    --                 ["o"] = function()
    --                     local menu = require("dropbar.api").get_current_dropbar_menu()
    --                     if not menu then
    --                         return
    --                     end
    --                     vim.cmd.normal("0")
    --                     local cursor = vim.api.nvim_win_get_cursor(menu.win)
    --                     local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
    --                     if component then
    --                         menu:click_on(component, nil, 1, "l")
    --                     end
    --                 end,
    --             },
    --         },
    --     },
    -- },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        event = {
            "UIEnter",
        },
        opts = {
            options = {
                section_separators = { left = "", right = "" },
                component_separators = { left = "|", right = "|" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    "branch",
                    {
                        "diff",
                        symbols = {
                            added = variables.icons.git.added,
                            modified = variables.icons.git.modified,
                            removed = variables.icons.git.deleted,
                        },
                    },
                    {
                        "diagnostics",
                        symbols = variables.icons.diagnostics,
                    },
                },
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
                lualine_z = {
                    {
                        function()
                            if vim.fn.mode():find("v") then
                                return ("chars: %s"):format(vim.fn.wordcount().visual_chars)
                            elseif vim.fn.mode():find("V") then
                                local visual_start = vim.fn.line("v")
                                local visual_end = vim.fn.line(".")
                                local lines = visual_start <= visual_end and visual_end - visual_start + 1 or visual_start - visual_end + 1

                                return ("lines: %s"):format(lines)
                            end

                            return ""
                        end,
                    },
                    "location",
                },
            },
            inactive_sections = {
                lualine_c = { "filename", "filesize" },
            },
        },
    },

    {
        "RRethy/vim-illuminate",
        config = function(_, opts)
            require("illuminate").configure(opts)
        end,
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
        keys = {
            { "<f7>",   function() require("illuminate").goto_next_reference(false) end, desc = "Go to next reference",     mode = "n" },
            { "<s-f7>", function() require("illuminate").goto_prev_reference(false) end, desc = "Go to previous reference", mode = "n" },
        },
        opts = {
            filetypes_denylist = variables.skip_filetype_list3,
        },
    },
}
