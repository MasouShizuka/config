local utils = require("config.utils")
local variables = require("config.variables")

return {
    {
        "jose-elias-alvarez/null-ls.nvim",
        config = function(_, opts)
            -- local augroup = vim.api.nvim_create_augroup("LspAutoFormat", {})
            require("null-ls").setup({
                -- 保存时自动格式化
                -- on_attach = function(client, bufnr)
                --     if client.supports_method("textDocument/formatting") then
                --         vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })
                --         vim.api.nvim_create_autocmd("BufWritePre", {
                --             buffer = bufnr,
                --             callback = variables.format,
                --             desc = "Lsp auto format when saving",
                --             group = augroup,
                --         })
                --     end
                -- end,
                sources = {},
            })
        end,
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
            "BufNewFile",
            "BufReadPost",
        },
    },

    {
        "neovim/nvim-lspconfig",
        config = function(_, opts)
            vim.lsp.set_log_level("OFF")

            -- Floating windows borders
            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or "rounded"
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            -- Customizing how diagnostics are displayed
            vim.diagnostic.config({
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●", -- Could be '●', '▎', 'x'
                    -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
                    -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
                    -- prefix = "icons",
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = false,
            })

            -- Change diagnostic symbols in the sign column (gutter)
            local icons = variables.icons.diagnostics
            for type, icon in pairs(icons) do
                local hl = "DiagnosticSign" .. type:gsub("^%l", string.upper)
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- Inlay hint
            local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
            if inlay_hint then
                vim.api.nvim_create_autocmd("LspAttach", {
                    callback = function(args)
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if client.server_capabilities.inlayHintProvider then
                            inlay_hint(args.buf, true)
                        end
                    end,
                    desc = "Enable lsp inlay hint",
                    group = vim.api.nvim_create_augroup("LspInlayHint", { clear = true }),
                })
            end

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            -- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)

            -- 由 trouble 设置
            -- vim.keymap.set("n", "<s-f8>", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic", silent = true })
            -- vim.keymap.set("n", "<f8>", vim.diagnostic.goto_next, { desc = "Go to next diagnostic", silent = true }))

            -- vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.api.nvim_set_option_value("omnifunc", "u:lua.vim.lsp.omnifunc", { buf = ev.buf })

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    -- local opts = { buffer = ev.buf, silent = true }
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration", silent = true })

                    -- 由 glance 设置
                    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition", silent = true })

                    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover", silent = true })

                    -- 由 glance 设置
                    -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Go to implementation", silent = true })

                    vim.keymap.set("n", "gS", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help", silent = true })
                    -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
                    -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
                    -- vim.keymap.set("n", "<space>wl", function()
                    --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    -- end, opts)

                    -- 由 glance 设置
                    -- vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Go to type definition", silent = true })

                    vim.keymap.set("n", "<f2>", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename", silent = true })
                    vim.keymap.set({ "n", "x" }, variables.keymap["<c-;>"], vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code action", silent = true })

                    -- 由 glance 设置
                    -- vim.keymap.set("n", "ge", vim.lsp.buf.references, { buffer = ev.buf, desc = "Go to references", silent = true })

                    vim.keymap.set({ "n", "x" }, "<leader>f", variables.format, { buffer = ev.buf, desc = "Format", silent = true })
                end,
                desc = "Lsp keymap",
                group = vim.api.nvim_create_augroup("LspKeymap", {}),
            })
        end,
        dependencies = {
            {
                "dnlhc/glance.nvim",
                cmd = {
                    "Glance references",
                    "Glance definitions",
                    "Glance type_definitions",
                    "Glance implementations",
                },
                keys = {
                    { "gd", function() vim.api.nvim_command("Glance definitions") end,      desc = "Glance definitions",      mode = "n" },
                    { "ge", function() vim.api.nvim_command("Glance references") end,       desc = "Glance references",       mode = "n" },
                    { "gi", function() vim.api.nvim_command("Glance implementations") end,  desc = "Glance implementations",  mode = "n" },
                    { "gy", function() vim.api.nvim_command("Glance type_definitions") end, desc = "Glance type_definitions", mode = "n" },
                },
                opts = function()
                    local glance = require("glance")
                    local actions = glance.actions

                    return {
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
                    }
                end,
            },

            {
                "folke/neodev.nvim",
                enabled = not variables.is_vscode,
                event = {
                    "User ConfigFile",
                },
                init = function()
                    vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
                        callback = function()
                            local cwd = vim.fn.getcwd()
                            if variables.is_windows then
                                cwd = cwd:gsub("\\", "/")
                            end

                            if cwd == variables.config_path then
                                utils.event("ConfigFile")
                                vim.api.nvim_del_augroup_by_name("ConfigFile")
                            end
                        end,
                        desc = "Config file detection",
                        group = vim.api.nvim_create_augroup("ConfigFile", { clear = true }),
                    })
                end,
                opts = {},
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
                    "nvim-tree/nvim-web-devicons",
                },
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
                "kosayoda/nvim-lightbulb",
                event = {
                    "BufNewFile",
                    "BufReadPost",
                },
                opts = {
                    autocmd = {
                        enabled = true,
                    },
                },
            },

            {
                "williamboman/mason-lspconfig.nvim",
                cmd = {
                    "LspInstall",
                    "LspUninstall",
                },
                config = function(_, opts)
                    local lspconfig = require("lspconfig")

                    local default_config = {
                        capabilities = vim.tbl_deep_extend(
                            "force",
                            {},
                            vim.lsp.protocol.make_client_capabilities(),
                            require("cmp_nvim_lsp").default_capabilities(),
                            opts.capabilities or {}
                        ),
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
                            lspconfig[server_name].setup(default_config)
                        end,
                    }
                    for lsp, setup in pairs(variables.lsp(lspconfig, default_config)) do
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

                    {
                        "utilyre/barbecue.nvim",
                        dependencies = {
                            "nvim-tree/nvim-web-devicons",
                            "SmiteshP/nvim-navic",
                        },
                        name = "barbecue",
                        opts = {
                            attach_navic = false, -- prevent barbecue from automatically attaching nvim-navic
                        },
                        version = "*",
                    },

                    "williamboman/mason.nvim",
                },
            },
        },
        enabled = not variables.is_vscode,
        event = {
            "BufNewFile",
            "BufReadPost",
        },
    },

    {
        "stevearc/aerial.nvim",
        cmd = {
            "AerialToggle",
            "AerialOpen",
            "AerialOpenAll",
            "AerialClose",
            "AerialCloseAll",
            "AerialNext",
            "AerialPrev",
            "AerialGo",
            "AerialInfo",
            "AerialNavToggle",
            "AerialNavOpen",
            "AerialNavClose",
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        opts = {
            keymaps = {
                ["?"] = "actions.show_help",
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.jump",
                ["l"] = "actions.jump",
                ["<2-LeftMouse>"] = "actions.jump",
                ["<C-v>"] = false,
                ["<C-s>"] = false,
                ["S"] = "actions.jump_vsplit",
                ["s"] = "actions.jump_split",
                ["p"] = "actions.scroll",
                ["<C-j>"] = false,
                ["<C-k>"] = false,
                ["J"] = "actions.down_and_scroll",
                ["K"] = "actions.up_and_scroll",
                ["{"] = "actions.prev",
                ["}"] = "actions.next",
                ["[["] = "actions.prev_up",
                ["h"] = "actions.prev_up",
                ["]]"] = "actions.next_up",
                ["q"] = "actions.close",
                ["o"] = "actions.tree_toggle",
                ["za"] = "actions.tree_toggle",
                ["O"] = "actions.tree_toggle_recursive",
                ["zA"] = "actions.tree_toggle_recursive",
                -- ["l"] = "actions.tree_open",
                ["zo"] = "actions.tree_open",
                ["L"] = false,
                ["zO"] = "actions.tree_open_recursive",
                -- ["h"] = "actions.tree_close",
                ["zc"] = "actions.tree_close",
                ["H"] = false,
                ["zC"] = "actions.tree_close_recursive",
                ["zr"] = "actions.tree_increase_fold_level",
                ["zR"] = "actions.tree_open_all",
                ["zm"] = "actions.tree_decrease_fold_level",
                ["zM"] = "actions.tree_close_all",
                ["zx"] = "actions.tree_sync_folds",
                ["zX"] = "actions.tree_sync_folds",
            },
            highlight_on_hover = true,
            show_guides = true,
        },
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
