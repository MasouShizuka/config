local variables = require("variables")

return {
    "akinsho/bufferline.nvim",
    cond = not variables.is_vscode,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<C-h>", function() vim.api.nvim_command("BufferLineCyclePrev") end, mode = "n" },
        { "<C-l>", function() vim.api.nvim_command("BufferLineCycleNext") end, mode = "n" },
    },
    lazy = false,
    opts = {
        options = {
            -- mode = "buffers" | "tabs", -- set to "tabs" to only show tabpages instead
            mode = "tabs",
            -- numbers = "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
            numbers = "ordinal",
            -- diagnostics = false | "nvim_lsp" | "coc",
            diagnostics = "nvim_lsp",
            -- offsets = {{filetype = "NvimTree", text = "File Explorer" | function , text_align = "left" | "center" | "right"}},
            offsets = {
                {
                    filetype = "NvimTree",
                    highlight = "Directory",
                    text = "File Explorer",
                    text_align = "center",
                },
            },
            -- separator_style = "slant" | "thick" | "thin" | { 'any', 'any' },
            separator_style = "thin",
            -- sort_by = "id" | "extension" | "relative_directory" | "directory" | "tabs" | function(buffer_a, buffer_b)
            -- -- add custom logic
            --     return buffer_a.modified > buffer_b.modified
            -- end
            sort_by = "tabs",
        }
    },
    version = "v3.*",
}
