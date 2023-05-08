local variables = require("variables")

return {
    "akinsho/bufferline.nvim",
    cond = not variables.is_vscode,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    event = { "UIEnter" },
    keys = {
        {
            "<C-h>",
            function()
                vim.api.nvim_command("BufferLineCyclePrev")
            end,
            mode = "n",
        },
        {
            "<C-l>",
            function()
                vim.api.nvim_command("BufferLineCycleNext")
            end,
            mode = "n",
        },
    },
    opts = {
        options = {
            -- mode = "buffers", -- set to "tabs" to only show tabpages instead
            mode = "tabs",
            -- numbers = "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
            numbers = "ordinal",
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
            separator_style = "slant",
            -- sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
            --     -- add custom logic
            --     return buffer_a.modified > buffer_b.modified
            -- end
            sort_by = "tabs",
        },
    },
    version = "v3.*",
}
