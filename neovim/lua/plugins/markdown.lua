local variables = require("variables")

return {
    {
        "ekickx/clipboard-image.nvim",
        cmd = { "PasteImg" },
        cond = not variables.is_vscode,
        config = function(_, opts)
            require("clipboard-image").setup(opts)

            vim.keymap.set("n", "<Leader>p", function()
                vim.api.nvim_command("PasteImg")
            end, { silent = true })
        end,
        opts = {
            default = {
                -- img_dir = "img",
                -- img_dir = "_images",
                img_dir = function()
                    return vim.fn.expand("%:.:h") .. "/_images_" .. vim.fn.expand("%:t:r")
                end,
                -- img_dir_txt = "img",
                -- img_dir_txt = "_images",
                img_dir_txt = function()
                    return "_images_" .. vim.fn.expand("%:t:r")
                end,
                img_name = function()
                    return os.date("%Y-%m-%d-%H-%M-%S")
                end,
                img_handler = function(img)
                end,
                affix = "%s",
            },
            asciidoc = {
                affix = "image::%s[]",
            },
            markdown = {
                affix = "![](%s)",
            },
        },
    },

    {
        "gaoDean/autolist.nvim",
        cond = not variables.is_vscode,
        config = function(_, opts)
            local autolist = require("autolist")
            autolist.setup()
            -- autolist.create_mapping_hook("i", "<CR>", autolist.new)
            autolist.create_mapping_hook("i", "<Tab>", autolist.indent)
            autolist.create_mapping_hook("i", "<S-Tab>", autolist.indent, "<C-D>")
            autolist.create_mapping_hook("n", "o", autolist.new)
            autolist.create_mapping_hook("n", "O", autolist.new_before)
            autolist.create_mapping_hook("n", ">>", autolist.indent)
            autolist.create_mapping_hook("n", "<<", autolist.indent)
            -- autolist.create_mapping_hook("n", "<C-r>", autolist.force_recalculate)
            -- autolist.create_mapping_hook("n", "<leader>x", autolist.invert_entry, "")
        end,
        ft = variables.tex_filetype,
    },

    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        cond = not variables.is_vscode,
        ft = "markdown",
    },
}
