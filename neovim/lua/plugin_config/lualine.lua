require("lualine").setup(
    {
        sections = {
            lualine_c = { "filename", "filesize" },
        },
        inactive_sections = {
            lualine_c = { "filename", "filesize" },
        },
    }
)
