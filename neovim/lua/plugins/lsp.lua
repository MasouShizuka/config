local variables = require("variables")

return {
    {
        "amrbashir/nvim-docs-view",
        cmd = { "DocsViewToggle", "DocsViewUpdate" },
        cond = not variables.is_vscode,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        keys = {
            {
                variables.alacritty_keymap["<C-4>"],
                function()
                    vim.api.nvim_command("DocsViewToggle")
                end,
                mode = "n",
            },
        },
        opts = {
            position = "right",
            -- 修改过源码
            height = function()
                return math.floor((vim.o.lines - vim.o.cmdheight) * 0.8)
            end,
            width = function()
                return math.floor(vim.o.columns * 0.2)
            end,
            update_mode = "auto",
        },
    },

    {
        "dnlhc/glance.nvim",
        cmd = {
            "Glance references",
            "Glance definitions",
            "Glance type_definitions",
            "Glance implementations",
        },
        cond = not variables.is_vscode,
        config = function(_, opts)
            local glance = require("glance")
            local actions = glance.actions
            glance.setup({
                border = {
                    enable = true, -- Show window borders. Only horizontal borders allowed
                    top_char = "―",
                    bottom_char = "―",
                },
                mappings = {
                    list = {
                        ["j"] = actions.next,     -- Bring the cursor to the next item in the list
                        ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
                        ["<Down>"] = actions.next,
                        ["<Up>"] = actions.previous,
                        ["<Tab>"] = actions.next_location,       -- Bring the cursor to the next location skipping groups in the list
                        ["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
                        ["<C-u>"] = actions.preview_scroll_win(5),
                        ["<C-d>"] = actions.preview_scroll_win(-5),
                        -- ["v"] = actions.jump_vsplit,
                        -- ["s"] = actions.jump_split,
                        ["v"] = false,
                        ["s"] = actions.jump_vsplit,
                        ["S"] = actions.jump_split,
                        ["t"] = actions.jump_tab,
                        ["<CR>"] = actions.jump,
                        ["o"] = actions.jump,
                        ["l"] = actions.jump,
                        -- ["<leader>l"] = actions.enter_win("preview"), -- Focus preview window
                        ["<leader>l"] = false,
                        ["<C-j>"] = actions.enter_win("preview"),
                        ["q"] = actions.close,
                        ["Q"] = actions.close,
                        ["<Esc>"] = actions.close,
                        ["<C-q>"] = actions.quickfix,
                        -- ["<Esc>"] = false -- disable a mapping
                    },
                    preview = {
                        ["Q"] = actions.close,
                        ["<Tab>"] = actions.next_location,
                        ["<S-Tab>"] = actions.previous_location,
                        ["<F4>"] = actions.next_location,
                        ["<S-F4>"] = actions.previous_location,
                        -- ["<leader>l"] = actions.enter_win("list"), -- Focus list window
                        ["<leader>l"] = false,
                        ["<C-j>"] = actions.enter_win("list"),
                    },
                },
                hooks = {
                    before_open = function(results, open, jump, method)
                        if #results == 1 then
                            jump(results[1]) -- argument is optional
                        else
                            open(results)    -- argument is optional
                        end
                    end,
                },
                folds = {
                    fold_closed = "",
                    fold_open = "",
                    folded = false, -- Automatically fold list on startup
                },
            })

            vim.keymap.set("n", "gd", function()
                vim.api.nvim_command("Glance definitions")
            end, { silent = true })
            vim.keymap.set("n", "ge", function()
                vim.api.nvim_command("Glance references")
            end, { silent = true })
            vim.keymap.set("n", "gi", function()
                vim.api.nvim_command("Glance implementations")
            end, { silent = true })
            vim.keymap.set("n", "gy", function()
                vim.api.nvim_command("Glance type_definitions")
            end, { silent = true })
        end,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        event = { "BufReadPre", "BufNewFile" },
    },

    {
        "folke/trouble.nvim",
        cond = not variables.is_vscode,
        cmd = {
            "Trouble",
            "TroubleClose",
            "TroubleRefresh",
            "TroubleToggle",
        },
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            {
                "<leader>xx",
                function()
                    vim.api.nvim_command("TroubleToggle")
                end,
                mode = "n",
            },
            {
                "<leader>xw",
                function()
                    vim.api.nvim_command("TroubleToggle workspace_diagnostics")
                end,
                mode = "n",
            },
            {
                "<leader>xd",
                function()
                    vim.api.nvim_command("TroubleToggle document_diagnostics")
                end,
                mode = "n",
            },
            {
                "<leader>xl",
                function()
                    vim.api.nvim_command("TroubleToggle loclist")
                end,
                mode = "n",
            },
            {
                "<leader>xq",
                function()
                    vim.api.nvim_command("TroubleToggle quickfix")
                end,
                mode = "n",
            },
            {
                "<F8>",
                function(...)
                    if not require("trouble").is_open() then
                        require("trouble").open(...)
                    end
                    require("trouble").next({ skip_groups = true, jump = true })
                end,
                mode = "n",
            },
            {
                "<S-F8>",
                function(...)
                    if not require("trouble").is_open() then
                        require("trouble").open(...)
                    end
                    require("trouble").previous({ skip_groups = true, jump = true })
                end,
                mode = "n",
            },
        },
        opts = {
            action_keys = {
                -- key mappings for actions in the trouble list
                -- map to {} to remove a mapping, for example:
                -- close = {},
                close = "q",                     -- close the list
                cancel = "<esc>",                -- cancel the preview and get back to your last window / buffer / cursor
                refresh = "r",                   -- manually refresh
                -- jump = { "<cr>", "<tab>" },   -- jump to the diagnostic or open / close folds
                jump = { "l", "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
                -- open_split = { "<c-x>" },     -- open buffer in new split
                -- open_vsplit = { "<c-v>" },    -- open buffer in new vsplit
                -- open_tab = { "<c-t>" },       -- open buffer in new tab
                open_split = { "S", "<c-x>" },  -- open buffer in new split
                open_vsplit = { "s", "<c-v>" }, -- open buffer in new vsplit
                open_tab = { "t", "<c-t>" },    -- open buffer in new tab
                jump_close = { "o" },           -- jump to the diagnostic and close the list
                toggle_mode = "m",              -- toggle between "workspace" and "document" diagnostics mode
                toggle_preview = "P",           -- toggle auto_preview
                hover = "K",                    -- opens a small popup with the full multiline message
                preview = "p",                  -- preview the diagnostic location
                close_folds = { "zM", "zm" },   -- close all folds
                open_folds = { "zR", "zr" },    -- open all folds
                toggle_fold = { "zA", "za" },   -- toggle fold of current file
                previous = "k",                 -- previous item
                next = "j",                     -- next item
            },
            use_diagnostic_signs = true,
        },
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        cond = not variables.is_vscode,
        dependencies = {
            {
                "jay-babu/mason-null-ls.nvim",
                cmd = { "NullLsInstall", "NullLsUninstall" },
                config = function(_, opts)
                    local handlers = {
                        function()
                            -- disables automatic setup of all null-ls sources
                        end,
                    }
                    for null_ls_builtin, setup in pairs(variables.null_ls_builtins(require("null-ls"))) do
                        handlers[null_ls_builtin] = setup
                    end

                    require("mason-null-ls").setup({
                        ensure_installed = variables.null_ls_builtins_list,
                        automatic_installation = true,
                        handlers = handlers,
                    })
                end,
                dependencies = {
                    "williamboman/mason.nvim",
                },
            },
            "nvim-lua/plenary.nvim",
        },
        event = { "BufReadPre", "BufNewFile" },
        opts = function()
            -- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            require("null-ls").setup({
                -- 保存时自动格式化
                -- on_attach = function(client, bufnr)
                --     if client.supports_method("textDocument/formatting") then
                --         vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                --         vim.api.nvim_create_autocmd("BufWritePre", {
                --             group = augroup,
                --             buffer = bufnr,
                --             callback = format,
                --         })
                --     end
                -- end,
                sources = {},
            })
        end,
    },

    {
        "kosayoda/nvim-lightbulb",
        cond = not variables.is_vscode,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            autocmd = {
                enabled = true,
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
        cond = not variables.is_vscode,
        config = function(_, opts)
            local icons = variables.icons.diagnostics
            for type, icon in pairs(icons) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- 设置 floating windows 的 border
            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or "rounded"
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            local format = function()
                local bufnr = vim.api.nvim_get_current_buf()
                vim.lsp.buf.format({
                    async = true,
                    bufnr = bufnr,
                    filter = function(client)
                        return client.name == "null-ls"
                    end,
                })
            end

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            -- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
            -- vim.keymap.set("n", "<F8>", vim.diagnostic.goto_prev)
            -- vim.keymap.set("n", "<S-F8>", vim.diagnostic.goto_next)
            -- vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.api.nvim_buf_set_option(ev.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf, silent = true }
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "gS", vim.lsp.buf.signature_help, opts)
                    -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
                    -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
                    -- vim.keymap.set("n", "<space>wl", function()
                    --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    -- end, opts)
                    -- vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
                    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
                    -- vim.keymap.set({ "n", "x" }, variables.alacritty_keymap["<C-;>"], vim.lsp.buf.code_action, opts)
                    -- vim.keymap.set("n", "ge", vim.lsp.buf.references, opts)
                    vim.keymap.set({ "n", "x" }, "<Leader>f", format, opts)
                end,
            })
        end,
        dependencies = {
            {
                "folke/neodev.nvim",
                cond = function()
                    if vim.fn.getcwd() == variables.config_path then
                        return true
                    else
                        return false
                    end
                end,
                opts = {},
            },
            {
                "williamboman/mason-lspconfig.nvim",
                cmd = { "LspInstall", "LspUninstall" },
                config = function(_, opts)
                    local default_config = {
                        capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        on_attach = function(client, bufnr)
                            if client.server_capabilities["documentSymbolProvider"] then
                                require("nvim-navic").attach(client, bufnr)
                            end
                        end,
                    }

                    local handlers = {
                        -- The first entry (without a key) will be the default handler
                        -- and will be called for each installed server that doesn't have
                        -- a dedicated handler.
                        function(server_name)
                            require("lspconfig")[server_name].setup(default_config)
                        end,
                    }
                    for lsp, setup in pairs(variables.lsp(require("lspconfig"), default_config)) do
                        handlers[lsp] = setup
                    end

                    require("mason-lspconfig").setup({
                        ensure_installed = variables.lsp_list,
                        automatic_installation = true,
                        handlers = handlers,
                    })
                end,
                dependencies = {
                    "hrsh7th/cmp-nvim-lsp",
                    "SmiteshP/nvim-navic",
                    "williamboman/mason.nvim",
                },
                opts = {
                    ensure_installed = variables.lsp_list,
                    automatic_installation = true,
                },
            },
        },
        event = { "BufReadPre", "BufNewFile" },
    },

    {
        "utilyre/barbecue.nvim",
        cond = not variables.is_vscode,
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-tree/nvim-web-devicons",
            "SmiteshP/nvim-navic",
        },
        event = { "BufReadPre", "BufNewFile" },
        name = "barbecue",
        opts = {
            attach_navic = false,
        },
        version = "*",
    },

    {
        "weilbith/nvim-code-action-menu",
        cmd = { "CodeActionMenu" },
        cond = not variables.is_vscode,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        keys = {
            {
                variables.alacritty_keymap["<C-;>"],
                function()
                    vim.api.nvim_command("CodeActionMenu")
                end,
                mode = { "n", "x" },
            },
        },
        init = function()
            vim.g.code_action_menu_window_border = "rounded"
        end,
    },
}
