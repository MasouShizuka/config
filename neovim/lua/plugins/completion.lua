local environment = require("utils.environment")
local filetype = require("utils.filetype")
local icons = require("utils.icons")
local keymap = require("utils.keymap")
local path = require("utils.path")

return {
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            vim.api.nvim_set_hl(0, "CmpItemMenu", { link = "purple" })

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
                    ["<s-down>"] = cmp.mapping(function(fallback)
                        if luasnip.choice_active() then
                            require("luasnip.extras.select_choice")()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<s-up>"] = cmp.mapping(function(fallback)
                        if luasnip.choice_active() then
                            require("luasnip.extras.select_choice")()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<c-j>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), { "i", "c" }),
                    ["<c-k>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), { "i", "c" }),
                    ["<c-d>"] = cmp.mapping.scroll_docs(4),
                    ["<c-u>"] = cmp.mapping.scroll_docs(-4),
                    [keymap["<c-space>"]] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        else
                            cmp.complete()
                        end
                    end),
                    ["<cr>"] = cmp.mapping.confirm({ select = false }),
                    ["<tab>"] = cmp.mapping.confirm({ select = true }),
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
                    format = function(entry, vim_item)
                        -- Kind icons
                        local kind_icons = icons.kinds
                        local icon = kind_icons[vim_item.kind]
                        if icon then
                            vim_item.kind = string.format("%s%s", icon, vim_item.kind) -- This concatonates the icons with the name of the item kind
                        end
                        -- Source
                        vim_item.menu = "[" .. entry.source.name:gsub("^%l", string.upper) .. "]"
                        return vim_item
                    end,
                },
                sources = cmp.config.sources({
                    { name = "luasnip" },
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "buffer" },
                    { name = "async_path" },
                    { name = "dotenv" },
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
                sources = cmp.config.sources({
                    { name = "cmdline_history" },
                    { name = "buffer" },
                }),
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                completion = {
                    completeopt = "menu,menuone,noinsert,noselect",
                },
                sources = cmp.config.sources({
                    { name = "cmdline_history" },
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "Man", "!" },
                        },
                    },
                    { name = "async_path" },
                }),
            })

            cmp.setup.filetype(filetype.tex_filetype_list, {
                sources = cmp.config.sources({
                    { name = "luasnip" },
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    {
                        name = "latex_symbols",
                        option = {
                            strategy = 2,
                        },
                    },
                    { name = "spell" },
                    { name = "buffer" },
                    { name = "async_path" },
                }),
            })

            cmp.setup.filetype(filetype.text_filetype_list, {
                sources = cmp.config.sources({
                    { name = "spell" },
                    { name = "buffer" },
                    { name = "async_path" },
                }),
            })
        end,
        dependencies = {
            "dmitmel/cmp-cmdline-history",
            "f3fora/cmp-spell",
            "https://codeberg.org/FelipeLema/cmp-async-path.git",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "kdheepak/cmp-latex-symbols",

            {
                "L3MON4D3/LuaSnip",
                config = function(_, opts)
                    require("luasnip").setup(opts)
                    require("luasnip.loaders.from_vscode").lazy_load()
                    require("luasnip.loaders.from_vscode").lazy_load({
                        paths = { path.vscode_snippet_path },
                    })
                end,
                dependencies = {
                    "rafamadriz/friendly-snippets",
                },
                opts = {
                    enable_autosnippets = true,
                },
            },

            "saadparwaiz1/cmp_luasnip",
            "SergioRibera/cmp-dotenv",
        },
        enabled = not environment.is_vscode,
        event = {
            "CmdlineEnter",
            "InsertEnter",
        },
    },
}
