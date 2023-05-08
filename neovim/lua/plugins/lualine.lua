local variables = require("variables")

return {
    "nvim-lualine/lualine.nvim",
    cond = not variables.is_vscode,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
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
    event = { "UIEnter" },
}
