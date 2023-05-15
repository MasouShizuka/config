local variables = require("config.variables")

return {
    {
        "ekickx/clipboard-image.nvim",
        cmd = {
            "PasteImg",
        },
        config = function(_, opts)
            require("clipboard-image").setup(opts)
        end,
        enabled = not variables.is_vscode,
        keys = {
            { "<leader>p", function() vim.api.nvim_command("PasteImg") end, desc = "Paste img", mode = "n" },
        },
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
        config = function(_, opts)
            local autolist = require("autolist")
            autolist.setup()
            -- autolist.create_mapping_hook("i", "<cr>", autolist.new)
            autolist.create_mapping_hook("i", "<tab>", autolist.indent)
            autolist.create_mapping_hook("i", "<s-tab>", autolist.indent, "<c-D>")
            autolist.create_mapping_hook("n", "o", autolist.new)
            autolist.create_mapping_hook("n", "O", autolist.new_before)
            autolist.create_mapping_hook("n", ">>", autolist.indent)
            autolist.create_mapping_hook("n", "<<", autolist.indent)
            -- autolist.create_mapping_hook("n", "<c-r>", autolist.force_recalculate)
            -- autolist.create_mapping_hook("n", "<leader>x", autolist.invert_entry, "")
        end,
        enabled = not variables.is_vscode,
        ft = variables.tex_filetype,
    },

    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        enabled = not variables.is_vscode,
        ft = "markdown",
    },
}
