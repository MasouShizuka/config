local variables = require("config.variables")

return {
    {
        "amrbashir/nvim-docs-view",
        cmd = {
            "DocsViewToggle",
            "DocsViewUpdate",
        },
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        enabled = not variables.is_vscode,
        lazy = true,
        opts = {
            position = "right",
            -- 修改过源码
            height = function() return math.floor((vim.o.lines - vim.o.cmdheight) * 0.8) end,
            width = function() return math.floor(vim.o.columns * 0.2) end,
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
                        ["<down>"] = actions.next,
                        ["<up>"] = actions.previous,
                        ["<tab>"] = actions.next_location,       -- Bring the cursor to the next location skipping groups in the list
                        ["<s-tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
                        ["<c-u>"] = actions.preview_scroll_win(5),
                        ["<c-d>"] = actions.preview_scroll_win(-5),
                        -- ["v"] = actions.jump_vsplit,
                        -- ["s"] = actions.jump_split,
                        ["v"] = false,
                        ["s"] = actions.jump_vsplit,
                        ["S"] = actions.jump_split,
                        ["t"] = actions.jump_tab,
                        ["<cr>"] = actions.jump,
                        ["o"] = actions.jump,
                        ["l"] = actions.jump,
                        -- ["<leader>l"] = actions.enter_win("preview"), -- Focus preview window
                        ["<leader>l"] = false,
                        ["<c-j>"] = actions.enter_win("preview"),
                        ["q"] = actions.close,
                        ["Q"] = actions.close,
                        ["<esc>"] = actions.close,
                        ["<c-q>"] = actions.quickfix,
                        -- ["<esc>"] = false -- disable a mapping
                    },
                    preview = {
                        ["Q"] = actions.close,
                        ["<tab>"] = actions.next_location,
                        ["<s-tab>"] = actions.previous_location,
                        ["<f4>"] = actions.next_location,
                        ["<s-f4>"] = actions.previous_location,
                        -- ["<leader>l"] = actions.enter_win("list"), -- Focus list window
                        ["<leader>l"] = false,
                        ["<c-j>"] = actions.enter_win("list"),
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
        end,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        enabled = not variables.is_vscode,
        keys = {
            { "gd", function() vim.api.nvim_command("Glance definitions") end,      desc = "Glance definitions",      mode = "n" },
            { "ge", function() vim.api.nvim_command("Glance references") end,       desc = "Glance references",       mode = "n" },
            { "gi", function() vim.api.nvim_command("Glance implementations") end,  desc = "Glance implementations",  mode = "n" },
            { "gy", function() vim.api.nvim_command("Glance type_definitions") end, desc = "Glance type_definitions", mode = "n" },
        },
    },

    {
        "folke/trouble.nvim",
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
        enabled = not variables.is_vscode,
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.register({
                    mode = "n",
                    ["<leader>x"] = {
                        name = "+trouble",
                    },
                })
            end
        end,
        keys = {
            { "<leader>xx", function() vim.api.nvim_command("TroubleToggle") end,                       desc = "Trouble",               mode = "n" },
            { "<leader>xw", function() vim.api.nvim_command("TroubleToggle workspace_diagnostics") end, desc = "Workspace diagnostics", mode = "n" },
            { "<leader>xd", function() vim.api.nvim_command("TroubleToggle document_diagnostics") end,  desc = "Document diagnostics",  mode = "n" },
            { "<leader>xl", function() vim.api.nvim_command("TroubleToggle loclist") end,               desc = "Loclist",               mode = "n" },
            { "<leader>xq", function() vim.api.nvim_command("TroubleToggle quickfix") end,              desc = "Quickfix",              mode = "n" },
            {
                "<f8>",
                function(...)
                    if not require("trouble").is_open() then
                        require("trouble").open(...)
                    end
                    require("trouble").next({ skip_groups = true, jump = true })
                end,
                desc = "Next",
                mode = "n",
            },
            {
                "<s-f8>",
                function(...)
                    if not require("trouble").is_open() then
                        require("trouble").open(...)
                    end
                    require("trouble").previous({ skip_groups = true, jump = true })
                end,
                desc = "Previous",
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
        dependencies = {
            {
                "jay-babu/mason-null-ls.nvim",
                cmd = {
                    "NullLsInstall",
                    "NullLsUninstall",
                },
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
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
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
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        opts = {
            autocmd = {
                enabled = true,
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
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

            vim.lsp.set_log_level("OFF")

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
            -- vim.keymap.set("n", "<s-f8>", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic", silent = true })
            -- vim.keymap.set("n", "<f8>", vim.diagnostic.goto_next, { desc = "Go to next diagnostic", silent = true }))
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
                    -- local opts = { buffer = ev.buf, silent = true }
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration", silent = true })
                    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition", silent = true })
                    -- 由 nvim-ufo 设置
                    -- vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover", silent = true })
                    -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Go to implementation", silent = true })
                    vim.keymap.set("n", "gS", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help", silent = true })
                    -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
                    -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
                    -- vim.keymap.set("n", "<space>wl", function()
                    --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    -- end, opts)
                    -- vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Go to type definition", silent = true })
                    vim.keymap.set("n", "<f2>", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename", silent = true })
                    -- vim.keymap.set({ "n", "x" }, variables.alacritty_keymap["<c-;>"], vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code action", silent = true })
                    -- vim.keymap.set("n", "ge", vim.lsp.buf.references, { buffer = ev.buf, desc = "Go to references", silent = true })
                    vim.keymap.set({ "n", "x" }, "<leader>f", format, { buffer = ev.buf, desc = "Format", silent = true })
                end,
            })
        end,
        dependencies = {
            {
                "folke/neodev.nvim",
                cond = function()
                    if variables.is_vscode then
                        return false
                    end

                    local cwd = vim.fn.getcwd()
                    if variables.is_windows then
                        cwd = string.gsub(cwd, "\\", "/")
                    end
                    if cwd == variables.config_path then
                        return true
                    end

                    return false
                end,
                opts = {},
            },
            {
                "williamboman/mason-lspconfig.nvim",
                cmd = {
                    "LspInstall",
                    "LspUninstall",
                },
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
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
    },

    {
        "weilbith/nvim-code-action-menu",
        cmd = {
            "CodeActionMenu",
        },
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        enabled = not variables.is_vscode,
        keys = {
            { variables.keymap["<c-;>"], function() vim.api.nvim_command("CodeActionMenu") end, desc = "Code action menu", mode = { "n", "x" } },
        },
        init = function()
            vim.g.code_action_menu_window_border = "rounded"
        end,
    },

    {
        "williamboman/mason.nvim",
        build = function()
            vim.api.nvim_command("MasonUpdate")

            -- 更新所有已经安装的 mason package
            local registry_avail, registry = pcall(require, "mason-registry")
            if not registry_avail then
                vim.api.nvim_err_writeln("Unable to access mason registry")
                return
            end
            vim.notify("Mason: Checking for package updates...")
            registry.update(vim.schedule_wrap(function(success, updated_registries)
                if success then
                    local installed_pkgs = registry.get_installed_packages()
                    local running = #installed_pkgs
                    local no_pkgs = running == 0

                    if no_pkgs then
                        vim.notify("Mason: No updates available")
                    else
                        local updated = false
                        for _, pkg in ipairs(installed_pkgs) do
                            pkg:check_new_version(function(update_available, version)
                                if update_available then
                                    updated = true
                                    vim.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
                                    pkg:install():on("closed", function()
                                        running = running - 1
                                        if running == 0 then
                                            vim.notify("Mason: Update Complete")
                                        end
                                    end)
                                else
                                    running = running - 1
                                    if running == 0 then
                                        if updated then
                                            vim.notify("Mason: Update Complete")
                                        else
                                            vim.notify("Mason: No updates available")
                                        end
                                    end
                                end
                            end)
                        end
                    end
                else
                    vim.notify(("Failed to update registries: %s"):format(updated_registries), vim.log.levels.ERROR)
                end
            end))
        end,
        cmd = {
            "Mason",
            "MasonUpdate",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
        },
        enabled = not variables.is_vscode,
        opts = {
            install_root_dir = variables.mason_install_root_path,
            log_level = vim.log.levels.OFF,
            ui = {
                border = "rounded",
            },
        },
    },
}
