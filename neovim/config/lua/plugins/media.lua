return {
    {
        "HakonHarnes/img-clip.nvim",
        cmd = {
            "PasteImage",
        },
        opts = {
            default = {
                -- file and directory options
                ---@type string | fun(): string
                dir_path = function() -- directory path to save images to, can be relative (cwd or current file) or absolute
                    return "_images_" .. vim.fn.expand("%:t:r")
                end,
                file_name = "%Y-%m-%d-%H-%M-%S", ---@type string | fun(): string
                relative_to_current_file = true, ---@type boolean | fun(): boolean

                -- prompt options
                prompt_for_file_name = false, ---@type boolean | fun(): boolean
            },
        },
    },
}
