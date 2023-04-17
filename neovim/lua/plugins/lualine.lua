local variables = require("variables")

return {
    "nvim-lualine/lualine.nvim",
    cond = not variables.is_vscode,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        sections = {
            lualine_c = { "filename", "filesize" },
            lualine_x = { {
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
                color = { fg = "#ff9e64" },
            }, "encoding", "fileformat", "filetype" },
        },
        inactive_sections = {
            lualine_c = { "filename", "filesize" },
        },
    },
}
