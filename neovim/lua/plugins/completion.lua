local variables = require("config.variables")

return {
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<down>"] = cmp.mapping({
                        i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                        c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    }),
                    ["<up>"] = cmp.mapping({
                        i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                        c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    }),
                    ["<s-right>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(1) then
                            luasnip.jump(1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<s-left>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<c-j>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), { "i", "c" }),
                    ["<c-k>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), { "i", "c" }),
                    ["<c-d>"] = cmp.mapping.scroll_docs(4),
                    ["<c-u>"] = cmp.mapping.scroll_docs(-4),
                    [variables.keymap["<c-space>"]] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        else
                            cmp.complete()
                        end
                    end),
                    ["<cr>"] = cmp.mapping.confirm({ select = false }),
                    -- ["<tab>"] = cmp.mapping.confirm({ select = true }),
                }),
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
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
                    { name = "luasnip" },
                    { name = "luasnip_choice" },
                    { name = "buffer" },
                    { name = "path" },
                }),
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                experimental = { ghost_text = { hl_group = "LspCodeLens" } },
            })

            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                completion = {
                    completeopt = "menu,menuone,noinsert,noselect",
                },
                sources = {
                    { name = "cmdline_history" },
                    { name = "buffer" },
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                completion = {
                    completeopt = "menu,menuone,noinsert,noselect",
                },
                sources = {
                    { name = "path" },
                    { name = "cmdline_history" },
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "Man", "!" },
                        },
                    },
                },
            })

            require("cmp").setup.filetype({
                "markdown",
                -- 由 texlab 管理
                -- "plaintex",
                -- "tex",
                "text",
            }, {
                sources = cmp.config.sources({
                    { name = "luasnip" },
                    { name = "luasnip_choice" },
                    {
                        name = "latex_symbols",
                        option = {
                            strategy = 2,
                        },
                    },
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
        dependencies = {
            "dmitmel/cmp-cmdline-history",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-path",
            "kdheepak/cmp-latex-symbols",

            {
                "saadparwaiz1/cmp_luasnip",
                dependencies = {
                    {
                        "L3MON4D3/cmp-luasnip-choice",
                        opts = {
                            auto_open = true,
                        },
                    },

                    {
                        "L3MON4D3/LuaSnip",
                        config = function(_, opts)
                            require("luasnip").setup(opts)
                            require("luasnip.loaders.from_vscode").lazy_load()
                            require("luasnip.loaders.from_vscode").lazy_load({
                                paths = { variables.vscode_snippet_path },
                            })
                        end,
                        dependencies = {
                            "rafamadriz/friendly-snippets",
                        },
                        opts = {
                            enable_autosnippets = true,
                        },
                    },
                },
            },
        },
        enabled = not variables.is_vscode,
        event = {
            "CmdlineEnter",
            "InsertEnter",
        },
        version = false,
    },
}
