vim.keymap.set("n", "<leader>p", function()
    vim.api.nvim_command("PasteImg")
end, { silent = true })

require("clipboard-image").setup(
    {
        default = {
            -- img_dir = "img",
            img_dir = "_images",
            -- img_dir_txt = "img",
            img_dir_txt = "_images",
            img_name = function()
                return os.date "%Y-%m-%d-%H-%M-%S"
            end,
            img_handler = function(img) end,
            affix = "%s",
        },
        asciidoc = {
            affix = "image::%s[]",
        },
        markdown = {
            affix = "![](%s)",
        },
    }
)
