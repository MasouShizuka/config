local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local filetype = require("utils.filetype")
            local utils = require("utils")

            local cmp = require("cmp")
            local is_luasnip_available = utils.is_available("LuaSnip")


            local snippet_plugin
            local snippet_source
            if is_luasnip_available then
                snippet_plugin = "cmp_luasnip"
                snippet_source = { name = "luasnip", priority = 100 }
            else
                snippet_plugin = "nvim-snippets"
                snippet_source = { name = "snippets", priority = 100 }
            end

            local lsp_source = { name = "nvim_lsp", priority = 100 }


            local sources = {}
            for source_plugin, source in pairs({
                [snippet_plugin] = snippet_source,
                ["cmp-nvim-lsp"] = lsp_source,
                ["cmp-path"] = { name = "path" },
                ["cmp-buffer"] = { name = "buffer" },
            }) do
                if utils.is_available(source_plugin) then
                    table.insert(sources, source)
                end
            end

            cmp.setup({
                mapping = {
                    ["<down>"] = cmp.mapping({
                        i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                        c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    }),
                    ["<up>"] = cmp.mapping({
                        i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                        c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    }),
                    ["<c-j>"] = cmp.mapping({
                        i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                        c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    }),
                    ["<c-k>"] = cmp.mapping({
                        i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                        c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    }),

                    ["<c-f>"] = cmp.mapping.scroll_docs(4),
                    ["<c-b>"] = cmp.mapping.scroll_docs(-4),

                    ["<c-s>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        else
                            cmp.complete()
                        end
                    end, { "i", "c" }),
                    ["<cr>"] = cmp.mapping.confirm({ select = false }),
                    ["<tab>"] = cmp.mapping({
                        i = cmp.mapping.confirm({ select = true }),
                        c = function()
                            if cmp.visible() then
                                cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                            else
                                cmp.complete()
                            end
                        end,
                    }),

                    ["<s-right>"] = cmp.mapping(function(fallback)
                        if is_luasnip_available then
                            if require("luasnip").jumpable(1) then
                                require("luasnip").jump(1)
                            else
                                fallback()
                            end
                        else
                            if vim.snippet.active({ direction = 1 }) then
                                vim.snippet.jump(1)
                            else
                                fallback()
                            end
                        end
                    end, { "i", "s" }),
                    ["<s-left>"] = cmp.mapping(function(fallback)
                        if is_luasnip_available then
                            if require("luasnip").jumpable(-1) then
                                require("luasnip").jump(-1)
                            else
                                fallback()
                            end
                        else
                            if vim.snippet.active({ direction = -1 }) then
                                vim.snippet.jump(-1)
                            else
                                fallback()
                            end
                        end
                    end, { "i", "s" }),
                    ["<s-down>"] = cmp.mapping(function(fallback)
                        if is_luasnip_available and require("luasnip").choice_active() then
                            require("luasnip.extras.select_choice")()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<s-up>"] = cmp.mapping(function(fallback)
                        if is_luasnip_available and require("luasnip").choice_active() then
                            require("luasnip.extras.select_choice")()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                snippet = {
                    expand = function(args)
                        if is_luasnip_available then
                            require("luasnip").lsp_expand(args.body)
                        else
                            vim.snippet.expand(args.body)
                        end
                    end,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                formatting = {
                    format = function(entry, vim_item)
                        local icons = require("utils.icons")
                        if icons.kinds[vim_item.kind] then
                            vim_item.kind = string.format("%s%s", icons.kinds[vim_item.kind], vim_item.kind)
                        end

                        vim_item.menu = "[" .. entry.source.name:gsub("^%l", string.upper) .. "]"

                        return vim_item
                    end,
                },
                sources = sources,
                experimental = {
                    ghost_text = { hl_group = "LspCodeLens" },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
            })


            sources = {}
            for source_plugin, source in pairs({
                ["cmp-cmdline-history"] = { name = "cmdline_history" },
                ["cmp-buffer"] = { name = "buffer" },
            }) do
                if utils.is_available(source_plugin) then
                    table.insert(sources, source)
                end
            end

            cmp.setup.cmdline({ "/", "?" }, {
                completion = {
                    completeopt = "menu,menuone,noinsert,noselect",
                },
                sources = sources,
            })


            sources = {}
            for source_plugin, source in pairs({
                ["cmp-cmdline-history"] = { name = "cmdline_history" },
                ["cmp-cmdline"] = { name = "cmdline" },
                ["cmp-path"] = { name = "path" },
            }) do
                if utils.is_available(source_plugin) then
                    table.insert(sources, source)
                end
            end

            cmp.setup.cmdline(":", {
                completion = {
                    completeopt = "menu,menuone,noinsert,noselect",
                },
                sources = sources,
            })


            for _, ft in ipairs(filetype.tex_filetype_list) do
                sources = {}

                for source_plugin, source in pairs({
                    [snippet_plugin] = snippet_source,
                    ["cmp-nvim-lsp"] = lsp_source,
                }) do
                    if utils.is_available(source_plugin) then
                        table.insert(sources, source)
                    end
                end

                if ft == "markdown" and utils.is_available("render-markdown.nvim") then
                    table.insert(sources, { name = "render-markdown" })
                end

                for source_plugin, source in pairs({
                    ["cmp-latex-symbols"] = {
                        name = "latex_symbols",
                        option = {
                            strategy = 2,
                        },
                    },
                    ["cmp-spell"] = {
                        name = "spell",
                        option = {
                            preselect_correct_word = false,
                        },
                    },
                    ["cmp-path"] = { name = "path" },
                    ["cmp-buffer"] = { name = "buffer" },
                }) do
                    if utils.is_available(source_plugin) then
                        table.insert(sources, source)
                    end
                end

                cmp.setup.filetype(ft, {
                    sources = sources,
                })
            end


            sources = {}
            for source_plugin, source in pairs({
                ["cmp-spell"] = {
                    name = "spell",
                    option = {
                        preselect_correct_word = false,
                    },
                },
                ["cmp-path"] = { name = "path" },
                ["cmp-buffer"] = { name = "buffer" },
            }) do
                if utils.is_available(source_plugin) then
                    table.insert(sources, source)
                end
            end

            cmp.setup.filetype(filetype.text_filetype_list, {
                sources = cmp.config.sources({
                    { name = "spell" },
                    { name = "path" },
                    { name = "buffer" },
                }),
            })


            -- lazyvim.util.cmp.auto_brackets
            cmp.event:on("confirm_done", function(event)
                if vim.tbl_contains({ "python" }, vim.bo.filetype) then
                    local entry = event.entry
                    local Kind = cmp.lsp.CompletionItemKind
                    local item = entry:get_completion_item()
                    if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
                        local cursor = vim.api.nvim_win_get_cursor(0)
                        local prev_char = vim.api.nvim_buf_get_text(0, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] + 1, {})[1]
                        if prev_char ~= "(" and prev_char ~= ")" then
                            local keys = vim.api.nvim_replace_termcodes("()<left>", false, false, true)
                            vim.api.nvim_feedkeys(keys, "i", true)
                        end
                    end
                end
            end)
        end,
        dependencies = {
            "dmitmel/cmp-cmdline-history",
            "f3fora/cmp-spell",

            -- {
            --     "garymjr/nvim-snippets",
            --     config = function(_, opts)
            --         require("snippets").setup(opts)
            --
            --         for _, source in pairs(require("cmp").core.sources) do
            --             if source.name == "snippets" then
            --                 source.get_keyword_pattern = function()
            --                     -- 添加 "." 的前缀匹配
            --                     return "\\%([^[:alnum:][:blank:]]\\|\\.*\\w\\+\\)"
            --                 end
            --
            --                 break
            --             end
            --         end
            --     end,
            --     dependencies = {
            --         "rafamadriz/friendly-snippets",
            --     },
            --     opts = {
            --         friendly_snippets = true,
            --         search_paths = { path.vscode_snippet_path },
            --     },
            -- },

            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "kdheepak/cmp-latex-symbols",

            {
                "saadparwaiz1/cmp_luasnip",
                dependencies = {
                    {
                        "L3MON4D3/LuaSnip",
                        config = function(_, opts)
                            local luasnip = require("luasnip")
                            luasnip.setup(opts)

                            require("luasnip.loaders.from_vscode").lazy_load()
                            require("luasnip.loaders.from_vscode").lazy_load({ paths = { path.vscode_snippet_path } })

                            vim.api.nvim_create_autocmd("User", {
                                callback = function()
                                    if luasnip.choice_active() then
                                        vim.schedule(function()
                                            require("luasnip.extras.select_choice")()
                                        end)
                                    end
                                end,
                                desc = "Auto select choice when entering choice",
                                group = vim.api.nvim_create_augroup("LuaSnipAutoSelectChoice", { clear = true }),
                                pattern = "LuasnipChoiceNodeEnter",
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
        enabled = not environment.is_vscode,
        event = {
            "CmdlineEnter",
            "InsertEnter",
        },
    },

    -- {
    --     "saghen/blink.cmp",
    --     dependencies = {
    --         -- {
    --         --     "L3MON4D3/LuaSnip",
    --         --     config = function(_, opts)
    --         --         local luasnip = require("luasnip")
    --         --         luasnip.setup(opts)
    --         --
    --         --         require("luasnip.loaders.from_vscode").lazy_load()
    --         --         require("luasnip.loaders.from_vscode").lazy_load({ paths = { path.vscode_snippet_path } })
    --         --
    --         --         vim.api.nvim_create_autocmd("User", {
    --         --             callback = function()
    --         --                 if luasnip.choice_active() then
    --         --                     vim.schedule(function()
    --         --                         require("luasnip.extras.select_choice")()
    --         --                     end)
    --         --                 end
    --         --             end,
    --         --             desc = "Auto select choice when entering choice",
    --         --             group = vim.api.nvim_create_augroup("LuaSnipAutoSelectChoice", { clear = true }),
    --         --             pattern = "LuasnipChoiceNodeEnter",
    --         --         })
    --         --     end,
    --         --     dependencies = {
    --         --         "rafamadriz/friendly-snippets",
    --         --     },
    --         --     opts = {
    --         --         enable_autosnippets = true,
    --         --     },
    --         -- },
    --
    --         "rafamadriz/friendly-snippets",
    --
    --         {
    --             "saghen/blink.compat",
    --             dependencies = {
    --                 "dmitmel/cmp-cmdline-history",
    --                 "f3fora/cmp-spell",
    --                 "kdheepak/cmp-latex-symbols",
    --             },
    --             opts = {},
    --         },
    --     },
    --     enabled = not environment.is_vscode,
    --     event = {
    --         "CmdlineEnter",
    --         "InsertEnter",
    --     },
    --     opts = function()
    --         local utils = require("utils")
    --
    --         utils.set_hl(0, "BlinkCmpGhostText", { link = "LspCodeLens" })
    --
    --
    --         local snippets
    --         local snippets_opts
    --         if utils.is_available("LuaSnip") then
    --             snippets = { preset = "luasnip" }
    --         else
    --             snippets_opts = {
    --                 search_paths = {
    --                     path.vscode_snippet_path,
    --                 },
    --             }
    --         end
    --
    --
    --         local providers = {
    --             path = {
    --                 opts = {
    --                     show_hidden_files_by_default = true,
    --                 },
    --             },
    --             snippets = {
    --                 opts = snippets_opts,
    --                 should_show_items = function(ctx)
    --                     return ctx.trigger.initial_kind ~= "trigger_character"
    --                 end,
    --             },
    --         }
    --
    --         for source_plugin, source in pairs({
    --             ["cmp-cmdline-history"] = {
    --                 name = "cmdline_history",
    --                 config = {},
    --             },
    --             ["cmp-latex-symbols"] = {
    --                 name = "latex_symbols",
    --                 config = {
    --                     opts = {
    --                         strategy = 2,
    --                     },
    --                 },
    --             },
    --             ["cmp-spell"] = {
    --                 name = "spell",
    --                 config = {
    --                     opts = {
    --                         preselect_correct_word = false,
    --                     },
    --                 },
    --             },
    --         }) do
    --             if utils.is_available(source_plugin) then
    --                 providers[source.name] = vim.tbl_deep_extend("force", {
    --                     name = source.name,
    --                     module = "blink.compat.source",
    --                 }, source.config)
    --             end
    --         end
    --
    --         if utils.is_available("render-markdown.nvim") then
    --             providers["markdown"] = {
    --                 name = "RenderMarkdown",
    --                 module = "render-markdown.integ.blink",
    --             }
    --         end
    --
    --         return {
    --             keymap = {
    --                 -- set to 'none' to disable the 'default' preset
    --                 preset = "none",
    --
    --                 ["<c-s>"] = { "show", "hide" },
    --                 ["<cr>"] = { "accept", "fallback" },
    --                 ["<tab>"] = { "select_and_accept", "fallback" },
    --
    --                 ["<s-right>"] = { "snippet_forward", "fallback" },
    --                 ["<s-left>"] = { "snippet_backward", "fallback" },
    --                 ["<s-down>"] = {
    --                     function(cmp)
    --                         if utils.is_available("LuaSnip") and require("luasnip").choice_active() then
    --                             cmp.hide()
    --                             require("luasnip.extras.select_choice")()
    --                             return true
    --                         end
    --                     end,
    --                     "fallback",
    --                 },
    --                 ["<s-up>"] = {
    --                     function(cmp)
    --                         if utils.is_available("LuaSnip") and require("luasnip").choice_active() then
    --                             cmp.hide()
    --                             require("luasnip.extras.select_choice")()
    --                             return true
    --                         end
    --                     end,
    --                     "fallback",
    --                 },
    --
    --                 ["<up>"] = { "select_prev", "fallback" },
    --                 ["<down>"] = { "select_next", "fallback" },
    --                 ["<c-j>"] = { "select_next", "fallback" },
    --                 ["<c-k>"] = { "select_prev", "fallback" },
    --
    --                 ["<c-b>"] = { "scroll_documentation_up", "fallback" },
    --                 ["<c-f>"] = { "scroll_documentation_down", "fallback" },
    --             },
    --
    --             snippets = snippets,
    --
    --             completion = {
    --                 list = {
    --                     selection = {
    --                         -- When `true`, inserts the completion item automatically when selecting it
    --                         -- You may want to bind a key to the `cancel` command (default <C-e>) when using this option,
    --                         -- which will both undo the selection and hide the completion menu
    --                         auto_insert = false,
    --                         -- auto_insert = function(ctx) return vim.bo.filetype ~= 'markdown' end
    --                     },
    --                 },
    --
    --                 menu = {
    --                     border = "rounded",
    --                     winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
    --
    --                     -- nvim-cmp style menu
    --                     draw = {
    --                         columns = {
    --                             { "label",      "label_description", gap = 1 },
    --                             { "kind_icon",  "kind" },
    --                             { "source_name" },
    --                         },
    --                     },
    --                 },
    --
    --                 documentation = {
    --                     -- Controls whether the documentation window will automatically show when selecting a completion item
    --                     auto_show = true,
    --                     window = {
    --                         border = "rounded",
    --                         winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
    --                     },
    --                 },
    --
    --                 -- Display a preview of the selected item on the current line
    --                 ghost_text = {
    --                     enabled = true,
    --                 },
    --             },
    --
    --             fuzzy = {
    --                 -- Controls which implementation to use for the fuzzy matcher.
    --                 --
    --                 -- 'prefer_rust_with_warning' (Recommended) If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available, emitting a warning message.
    --                 -- 'prefer_rust' If available, use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Fallback to the Lua implementation when not available.
    --                 -- 'rust' Always use the Rust implementation, automatically downloading prebuilt binaries on supported systems. Error if not available.
    --                 -- 'lua' Always use the Lua implementation, doesn't download any prebuilt binaries
    --                 --
    --                 -- See the prebuilt_binaries section for controlling the download behavior
    --                 implementation = "lua",
    --
    --                 -- Allows for a number of typos relative to the length of the query
    --                 -- Set this to 0 to match the behavior of fzf
    --                 -- Note, this does not apply when using the Lua implementation.
    --                 max_typos = function(keyword) return 0 end,
    --             },
    --
    --             sources = {
    --                 default = function(ctx)
    --                     local filetype = require("utils.filetype")
    --
    --                     local sources = {}
    --
    --                     local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
    --                     local success, node = pcall(vim.treesitter.get_node)
    --
    --                     if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
    --                         sources[#sources + 1] = "buffer"
    --                     elseif vim.tbl_contains(filetype.tex_filetype_list, ft) then
    --                         vim.list_extend(sources, { "snippets", "lsp" })
    --
    --                         if ft == "markdown" and utils.is_available("render-markdown.nvim") then
    --                             sources[#sources + 1] = "markdown"
    --                         end
    --
    --                         if utils.is_available("cmp-latex-symbols") then
    --                             sources[#sources + 1] = "latex_symbols"
    --                         end
    --
    --                         if utils.is_available("cmp-spell") then
    --                             sources[#sources + 1] = "spell"
    --                         end
    --
    --                         vim.list_extend(sources, { "path", "buffer" })
    --                     elseif vim.tbl_contains(filetype.text_filetype_list, ft) then
    --                         if utils.is_available("cmp-spell") then
    --                             sources[#sources + 1] = "spell"
    --                         end
    --
    --                         vim.list_extend(sources, { "path", "buffer" })
    --                     else
    --                         sources[#sources + 1] = "snippets"
    --
    --                         if vim.tbl_contains(require("utils.lsp").lsp_filetype_list, ft) then
    --                             sources[#sources + 1] = "lsp"
    --                         end
    --
    --                         vim.list_extend(sources, { "path", "buffer" })
    --                     end
    --
    --                     return sources
    --                 end,
    --
    --                 providers = providers,
    --             },
    --
    --             appearance = {
    --                 -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    --                 -- Useful for when your theme doesn't support blink.cmp
    --                 -- Will be removed in a future release
    --                 use_nvim_cmp_as_default = true,
    --                 kind_icons = require("utils.icons").kinds,
    --             },
    --
    --             cmdline = {
    --                 keymap = {
    --                     preset = "none",
    --
    --                     ["<c-s>"] = { "show", "hide" },
    --                     ["<cr>"] = { "accept_and_enter", "fallback" },
    --                     ["<tab>"] = { "select_and_accept", "fallback" },
    --
    --                     ["<up>"] = { "select_prev", "fallback" },
    --                     ["<down>"] = { "select_next", "fallback" },
    --                     ["<c-j>"] = { "select_next", "fallback" },
    --                     ["<c-k>"] = { "select_prev", "fallback" },
    --                 },
    --                 sources = function(ctx)
    --                     local sources = {}
    --
    --                     if utils.is_available("cmp-cmdline-history") then
    --                         sources[#sources + 1] = "cmdline_history"
    --                     end
    --
    --                     local type = vim.fn.getcmdtype()
    --                     -- Search forward and backward
    --                     if type == "/" or type == "?" then
    --                         sources[#sources + 1] = "buffer"
    --                     end
    --                     -- Commands
    --                     if type == ":" or type == "@" then
    --                         sources[#sources + 1] = "cmdline"
    --                     end
    --
    --                     return sources
    --                 end,
    --                 completion = {
    --                     list = {
    --                         selection = {
    --                             -- When `true`, will automatically select the first item in the completion list
    --                             preselect = false,
    --                         },
    --                     },
    --                     -- Whether to automatically show the window when new completion items are available
    --                     menu = { auto_show = true },
    --                 },
    --             },
    --         }
    --     end,
    --     -- use a release tag to download pre-built binaries
    --     version = "*",
    --     opts_extend = { "sources.default" },
    -- },
}
