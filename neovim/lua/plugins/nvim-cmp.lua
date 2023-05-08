local variables = require("variables")

return {
    "hrsh7th/nvim-cmp",
    cond = not variables.is_vscode,
    config = function()
        local cmp = require("cmp")
        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                ["<C-d>"] = cmp.mapping.scroll_docs(4),
                ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                [variables.alacritty_keymap["<C-Space>"]] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    else
                        cmp.complete()
                    end
                end),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ select = true })
                    elseif vim.fn["vsnip#available"](1) == 1 then
                        local keys = vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, false, true)
                        vim.api.nvim_feedkeys(keys, "n", false)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ select = true })
                    elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                        local keys = vim.api.nvim_replace_termcodes("<Plug>(vsnip-jump-prev)", true, false, true)
                        vim.api.nvim_feedkeys(keys, "n", false)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            formatting = {
                format = function(_, item)
                    local icons = variables.icons.kinds
                    if icons[item.kind] then
                        item.kind = icons[item.kind] .. item.kind
                    end
                    return item
                end,
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "vsnip" },
                { name = "path" },
                { name = "buffer" },
            }),
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            experimental = { ghost_text = { hl_group = "LspCodeLens" } },
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                {
                    name = "cmdline",
                    option = {
                        ignore_cmds = { "Man", "!" },
                    },
                },
            }, { { name = "path" } }),
        })

        require("cmp").setup.filetype(variables.tex_filetype, {
            sources = cmp.config.sources({
                { name = "vsnip" },
                {
                    name = "latex_symbols",
                    option = {
                        strategy = 2,
                    },
                },
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "path" },
                { name = "buffer" },
            }),
        })
    end,
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        {
            "hrsh7th/cmp-nvim-lsp",
            dependencies = {
                "neovim/nvim-lspconfig",
            },
        },
        {
            "hrsh7th/cmp-nvim-lsp-signature-help",
            dependencies = {
                "neovim/nvim-lspconfig",
            },
        },
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-vsnip",
        {
            "hrsh7th/vim-vsnip",
            init = function()
                vim.g.vsnip_snippet_dir = variables.vscode_snippet_path
            end,
        },
        "kdheepak/cmp-latex-symbols",
        "rafamadriz/friendly-snippets",
    },
    event = { "CmdlineEnter", "InsertEnter" },
    version = false,
}
