local utils = require("config.utils")
local variables = require("config.variables")

return {
    {
        "dnlhc/glance.nvim",
        cmd = {
            "Glance references",
            "Glance definitions",
            "Glance type_definitions",
            "Glance implementations",
        },
        enabled = not variables.is_vscode,
        keys = {
            { "gd", function() vim.api.nvim_command("Glance definitions") end,      desc = "Glance definitions",      mode = "n" },
            { "gi", function() vim.api.nvim_command("Glance implementations") end,  desc = "Glance implementations",  mode = "n" },
            { "gr", function() vim.api.nvim_command("Glance references") end,       desc = "Glance references",       mode = "n" },
            { "gy", function() vim.api.nvim_command("Glance type_definitions") end, desc = "Glance type_definitions", mode = "n" },
        },
        opts = function()
            local actions = require("glance").actions

            return {
                border = {
                    enable = true, -- Show window borders. Only horizontal borders allowed
                },
                mappings = {
                    list = {
                        -- ["j"] = actions.next,     -- Bring the cursor to the next item in the list
                        -- ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
                        -- ["<down>"] = actions.next,
                        -- ["<up>"] = actions.previous,
                        -- ["<tab>"] = actions.next_location,       -- Bring the cursor to the next location skipping groups in the list
                        -- ["<s-tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
                        -- ["<c-u>"] = actions.preview_scroll_win(5),
                        -- ["<c-d>"] = actions.preview_scroll_win(-5),
                        -- ["v"] = actions.jump_vsplit,
                        -- ["s"] = actions.jump_split,
                        ["s"] = false,
                        ["V"] = actions.jump_split,
                        -- ["t"] = actions.jump_tab,
                        -- ["<cr>"] = actions.jump,
                        -- ["o"] = actions.jump,
                        -- ["l"] = actions.open_fold,
                        ["l"] = actions.jump,
                        -- ["h"] = actions.close_fold,
                        -- ["<leader>l"] = actions.enter_win("preview"), -- Focus preview window
                        ["<leader>l"] = false,
                        ["<c-j>"] = actions.enter_win("preview"),
                        -- ["q"] = actions.close,
                        -- ["Q"] = actions.close,
                        -- ["<esc>"] = actions.close,
                        -- ["<c-q>"] = actions.quickfix,
                        -- ["<esc>"] = false -- disable a mapping
                    },
                    preview = {
                        -- ["Q"] = actions.close,
                        -- ["<tab>"] = actions.next_location,
                        -- ["<s-tab>"] = actions.previous_location,
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
                            local target_uri = results[1].uri or results[1].targetUri
                            target_uri = target_uri:gsub("%%3A", ":"):lower()

                            if target_uri == vim.uri_from_bufnr(0):lower() then
                                jump(results[1])
                            else
                                vim.api.nvim_command("tab sbuffer")
                                jump(results[1])
                            end

                            vim.cmd.normal("zt")
                        else
                            open(results)
                        end
                    end,
                    after_close = function()
                        vim.cmd.normal("zt")
                    end,
                },
                folds = {
                    folded = false, -- Automatically fold list on startup
                },
            }
        end,
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
        enabled = not variables.is_vscode,
        init = function()
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
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
            mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
            action_keys = {
                -- key mappings for actions in the trouble list
                -- map to {} to remove a mapping, for example:
                -- close = {},
                -- close = "q",                                      -- close the list
                -- cancel = "<esc>",                                 -- cancel the preview and get back to your last window / buffer / cursor
                -- refresh = "r",                                    -- manually refresh
                -- jump = { "<cr>", "<tab>", "<2-leftmouse>" },      -- jump to the diagnostic or open / close folds
                jump = { "<cr>", "<tab>", "<2-leftmouse>", "l" }, -- jump to the diagnostic or open / close folds
                -- open_split = { "<c-x>" },                         -- open buffer in new split
                -- open_vsplit = { "<c-v>" },                        -- open buffer in new vsplit
                -- open_tab = { "<c-t>" },                           -- open buffer in new tab
                open_split = { "V", "<c-x>" },  -- open buffer in new split
                open_vsplit = { "v", "<c-v>" }, -- open buffer in new vsplit
                open_tab = { "t", "<c-t>" },    -- open buffer in new tab
                -- jump_close = { "o" },                             -- jump to the diagnostic and close the list
                -- toggle_mode = "m",                                -- toggle between "workspace" and "document" diagnostics mode
                -- switch_severity = "s",                            -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
                -- toggle_preview = "P",                             -- toggle auto_preview
                -- hover = "K",                                      -- opens a small popup with the full multiline message
                -- preview = "p",                                    -- preview the diagnostic location
                -- open_code_href = "c",                             -- if present, open a URI with more information about the diagnostic error
                -- close_folds = { "zM", "zm" },                     -- close all folds
                -- open_folds = { "zR", "zr" },                      -- open all folds
                -- toggle_fold = { "zA", "za" },                     -- toggle fold of current file
                -- previous = "k",                                   -- previous item
                -- next = "j",                                       -- next item
                -- help = "?",                                       -- help menu
            },
            use_diagnostic_signs = true,
        },
    },

    {
        "j-hui/fidget.nvim",
        enabled = not variables.is_vscode,
        event = {
            "LspAttach",
        },
        opts = {
            notification = {
                window = {
                    winblend = 0,
                },
            },
            logger = {
                level = vim.log.levels.OFF,
            },
        },
    },

    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            {
                "jay-babu/mason-null-ls.nvim",
                cmd = {
                    "NullLsInstall",
                    "NullLsUninstall",
                },
                dependencies = {
                    "williamboman/mason.nvim",
                },
                opts = function()
                    local handlers = {
                        function()
                            -- disables automatic setup of all null-ls sources
                        end,
                    }
                    for null_ls_builtin, setup in pairs(variables.null_ls_builtins(require("null-ls"))) do
                        handlers[null_ls_builtin] = setup
                    end

                    return {
                        ensure_installed = variables.null_ls_builtins_list,
                        automatic_installation = true,
                        handlers = handlers,
                    }
                end,
            },

            "nvim-lua/plenary.nvim",
        },
        enabled = not variables.is_vscode,
        event = {
            "User LspFile",
        },
        opts = {},
    },

    {
        "neovim/nvim-lspconfig",
        config = function(_, opts)
            vim.lsp.set_log_level("OFF")

            -- Borders
            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or "rounded"
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            -- Customizing how diagnostics are displayed
            vim.diagnostic.config({
                virtual_text = {
                    source = "if_many",
                    spacing = 4,
                    prefix = "●",
                },
                update_in_insert = true,
                severity_sort = true,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local bufnr = args.buf

                    local function bool2str(bool)
                        return bool and "On" or "Off"
                    end

                    local function has_capability(capability, filter)
                        for _, client in ipairs(vim.lsp.get_active_clients(filter)) do
                            if client.supports_method(capability) then return true end
                        end
                        return false
                    end

                    local function add_buffer_autocmd(augroup, bufnr, autocmds)
                        if not vim.tbl_islist(autocmds) then
                            autocmds = { autocmds }
                        end
                        local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
                        if not cmds_found or vim.tbl_isempty(cmds) then
                            vim.api.nvim_create_augroup(augroup, { clear = false })
                            for _, autocmd in ipairs(autocmds) do
                                local events = autocmd.events
                                autocmd.events = nil
                                autocmd.group = augroup
                                autocmd.buffer = bufnr
                                vim.api.nvim_create_autocmd(events, autocmd)
                            end
                        end
                    end

                    local function del_buffer_autocmd(augroup, bufnr)
                        local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
                        if cmds_found then vim.tbl_map(function(cmd) vim.api.nvim_del_autocmd(cmd.id) end, cmds) end
                    end

                    local is_which_key_available, which_key = pcall(require, "which-key")
                    if is_which_key_available then
                        which_key.register({
                            mode = "n",
                            ["<leader>l"] = {
                                name = "+lsp",
                            },
                            buffer = bufnr,
                        })
                        which_key.register({
                            mode = "n",
                            ["<leader>lt"] = {
                                name = "+lsp toggle",
                            },
                            buffer = bufnr,
                        })
                    end

                    vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end, { buffer = bufnr, desc = "Hover diagnostics", silent = true })
                    if not utils.is_available("trouble.nvim") then
                        vim.keymap.set("n", "<s-f8>", function() vim.diagnostic.goto_prev() end, { buffer = bufnr, desc = "Previous diagnostic", silent = true })
                        vim.keymap.set("n", "<f8>", function() vim.diagnostic.goto_next() end, { buffer = bufnr, desc = "Next diagnostic", silent = true })
                    end

                    if utils.is_available("mason-lspconfig.nvim") then
                        vim.keymap.set("n", "<leader>li", function() vim.api.nvim_command("LspInfo") end, { buffer = bufnr, desc = "LSP information", silent = true })
                    end

                    if utils.is_available("none-ls.nvim") then
                        vim.keymap.set("n", "<leader>lI", function() vim.api.nvim_command("NullLsInfo") end, { buffer = bufnr, desc = "Null-ls information", silent = true })
                    end

                    if client.supports_method("textDocument/codeAction") then
                        vim.keymap.set({ "n", "x" }, variables.keymap["<c-;>"], function() vim.lsp.buf.code_action() end, { buffer = bufnr, desc = "LSP code action", silent = true })
                    end

                    if client.supports_method("textDocument/codeLens") then
                        vim.b.codelens_enabled = nil
                        if vim.g.codelens_enabled == nil then
                            vim.g.codelens_enabled = true
                        end

                        add_buffer_autocmd("lsp_codelens_refresh", bufnr, {
                            callback = function()
                                if not has_capability("textDocument/codeLens", { bufnr = bufnr }) then
                                    del_buffer_autocmd("lsp_codelens_refresh", bufnr)
                                    return
                                end
                                if vim.b[bufnr].codelens_enabled ~= nil then
                                    if vim.b[bufnr].codelens_enabled then
                                        vim.lsp.codelens.refresh()
                                    end
                                else
                                    if vim.g.codelens_enabled then
                                        vim.lsp.codelens.refresh()
                                    end
                                end
                            end,
                            desc = "Refresh codelens",
                            events = { "BufEnter", "InsertLeave" },
                        })

                        vim.keymap.set("n", "<leader>ltl", function()
                            local buffer_codelens_enabled = vim.b[bufnr].codelens_enabled
                            local global_codelens_enabled = vim.g.codelens_enabled
                            if buffer_codelens_enabled == nil then
                                buffer_codelens_enabled = false
                            end
                            if global_codelens_enabled == nil then
                                global_codelens_enabled = false
                            end

                            global_codelens_enabled = not global_codelens_enabled
                            vim.g.codelens_enabled = global_codelens_enabled

                            if not buffer_codelens_enabled and not global_codelens_enabled then
                                vim.lsp.codelens.clear()
                            end

                            vim.notify(string.format("CodeLens: %s", bool2str(global_codelens_enabled)), vim.log.levels.INFO, { title = "Global" })
                        end, { buffer = bufnr, desc = "Toggle LSP codelens", silent = true })
                        vim.keymap.set("n", "<leader>ltL", function()
                            local buffer_codelens_enabled = vim.b[bufnr].codelens_enabled
                            if buffer_codelens_enabled == nil then
                                buffer_codelens_enabled = false
                            end

                            buffer_codelens_enabled = not buffer_codelens_enabled
                            vim.b[bufnr].codelens_enabled = buffer_codelens_enabled

                            if not buffer_codelens_enabled then
                                vim.lsp.codelens.clear()
                            end

                            vim.notify(string.format("CodeLens: %s", bool2str(buffer_codelens_enabled)), vim.log.levels.INFO, { title = "Buffer" })
                        end, { buffer = bufnr, desc = "Toggle LSP codelens (buffer)", silent = true })

                        vim.keymap.set("n", "<leader>ll", function() vim.lsp.codelens.refresh() end, { buffer = bufnr, desc = "LSP CodeLens refresh", silent = true })
                        vim.keymap.set("n", "<leader>lL", function() vim.lsp.codelens.run() end, { buffer = bufnr, desc = "LSP CodeLens run", silent = true })
                    end

                    if client.supports_method("textDocument/declaration") then
                        vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, { buffer = bufnr, desc = "Declaration of current symbol", silent = true })
                    end

                    if not utils.is_available("glance.nvim") then
                        if client.supports_method("textDocument/definition") then
                            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { buffer = bufnr, desc = "Show the definition of current symbol", silent = true })
                        end

                        if client.supports_method("textDocument/implementation") then
                            vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, { buffer = bufnr, desc = "Implementation of current symbol", silent = true })
                        end

                        if client.supports_method("textDocument/typeDefinition") then
                            vim.keymap.set("n", "gy", function() vim.lsp.buf.type_definition() end, { buffer = bufnr, desc = "Definition of current type", silent = true })
                        end

                        if client.supports_method("textDocument/references") then
                            vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, { buffer = bufnr, desc = "References of current symbol", silent = true })
                        end
                    end

                    if client.supports_method("textDocument/formatting") then
                        local format = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end

                        vim.keymap.set({ "n", "x" }, "<leader>f", format, { buffer = bufnr, desc = "Format buffer", silent = true })

                        vim.b.autoformat_enabled = nil
                        if vim.g.autoformat_enabled == nil then
                            vim.g.autoformat_enabled = false
                        end

                        add_buffer_autocmd("lsp_auto_format", bufnr, {
                            callback = function()
                                if not has_capability("textDocument/formatting", { bufnr = bufnr }) then
                                    del_buffer_autocmd("lsp_auto_format", bufnr)
                                    return
                                end
                                if vim.b[bufnr].autoformat_enabled ~= nil then
                                    if vim.b[bufnr].autoformat_enabled then
                                        format()
                                    end
                                else
                                    if vim.g.autoformat_enabled then
                                        format()
                                    end
                                end
                            end,
                            desc = "Autoformat on save",
                            events = "BufWritePre",
                        })

                        vim.keymap.set("n", "<leader>ltf", function()
                            local global_autoformat_enabled = vim.g.autoformat_enabled
                            if global_autoformat_enabled == nil then
                                global_autoformat_enabled = false
                            end

                            global_autoformat_enabled = not global_autoformat_enabled
                            vim.g.autoformat_enabled = global_autoformat_enabled

                            vim.notify(string.format("AutoFormat: %s", bool2str(global_autoformat_enabled)), vim.log.levels.INFO, { title = "Global" })
                        end, { buffer = bufnr, desc = "Toggle autoformatting", silent = true })
                        vim.keymap.set("n", "<leader>ltF", function()
                            local buffer_autoformat_enabled = vim.b[bufnr].autoformat_enabled
                            if buffer_autoformat_enabled == nil then
                                buffer_autoformat_enabled = false
                            end

                            buffer_autoformat_enabled = not buffer_autoformat_enabled
                            vim.b[bufnr].autoformat_enabled = buffer_autoformat_enabled

                            vim.notify(string.format("Buffer AutoFormat: %s", bool2str(buffer_autoformat_enabled)), vim.log.levels.INFO, { title = "Buffer" })
                        end, { buffer = bufnr, desc = "Toggle autoformatting (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/documentHighlight") then
                        add_buffer_autocmd("lsp_document_highlight", bufnr, {
                            {
                                callback = function()
                                    if not has_capability("textDocument/documentHighlight", { bufnr = bufnr }) then
                                        del_buffer_autocmd("lsp_document_highlight", bufnr)
                                        return
                                    end
                                    vim.lsp.buf.document_highlight()
                                end,
                                desc = "Highlight references when cursor holds",
                                events = { "CursorHold", "CursorHoldI" },
                            },
                            {
                                callback = function()
                                    vim.lsp.buf.clear_references()
                                end,
                                desc = "Clear references when cursor moves",
                                events = { "BufLeave", "CursorMoved", "CursorMovedI" },
                            },
                        })
                    end

                    if client.supports_method("textDocument/hover") then
                        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { buffer = bufnr, desc = "Hover symbol details", silent = true })
                    end

                    if client.supports_method("textDocument/inlayHint") then
                        vim.b.inlay_hints_enabled = nil
                        if vim.g.inlay_hints_enabled == nil then
                            vim.g.inlay_hints_enabled = true
                        end

                        if vim.b[bufnr].inlay_hints_enabled ~= nil then
                            if vim.b[bufnr].inlay_hints_enabled then
                                vim.lsp.inlay_hint.enable(bufnr, true)
                            end
                        else
                            if vim.g.inlay_hints_enabled then
                                vim.lsp.inlay_hint.enable(bufnr, true)
                            end
                        end

                        vim.keymap.set("n", "<leader>lth", function()
                            local buffer_inlay_hints_enabled = vim.b[bufnr].inlay_hints_enabled
                            local global_inlay_hints_enabled = vim.g.inlay_hints_enabled
                            if buffer_inlay_hints_enabled == nil then
                                buffer_inlay_hints_enabled = false
                            end
                            if global_inlay_hints_enabled == nil then
                                global_inlay_hints_enabled = false
                            end

                            global_inlay_hints_enabled = not global_inlay_hints_enabled
                            vim.g.inlay_hints_enabled = global_inlay_hints_enabled

                            local enabled = buffer_inlay_hints_enabled or global_inlay_hints_enabled
                            if enabled ~= vim.lsp.inlay_hint.get({ bufnr = bufnr }) then
                                vim.lsp.inlay_hint.enable(bufnr, enabled)
                            end

                            vim.notify(string.format("Inlay Hints: %s", bool2str(global_inlay_hints_enabled)), vim.log.levels.INFO, { title = "Global" })
                        end, { buffer = bufnr, desc = "Toggle LSP inlay hints", silent = true })
                        vim.keymap.set("n", "<leader>ltH", function()
                            local buffer_inlay_hints_enabled = vim.b[bufnr].inlay_hints_enabled
                            if buffer_inlay_hints_enabled == nil then
                                buffer_inlay_hints_enabled = false
                            end

                            buffer_inlay_hints_enabled = not buffer_inlay_hints_enabled
                            vim.b[bufnr].inlay_hints_enabled = buffer_inlay_hints_enabled

                            local enabled = buffer_inlay_hints_enabled
                            if enabled ~= vim.lsp.inlay_hint.get({ bufnr = bufnr }) then
                                vim.lsp.inlay_hint.enable(bufnr, enabled)
                            end

                            vim.notify(string.format("Inlay Hints: %s", bool2str(buffer_inlay_hints_enabled)), vim.log.levels.INFO, { title = "Buffer" })
                        end, { buffer = bufnr, desc = "Toggle LSP inlay hints (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/rename") then
                        vim.keymap.set("n", "<f2>", function() vim.lsp.buf.rename() end, { buffer = bufnr, desc = "Rename current symbol", silent = true })
                    end

                    if client.supports_method("textDocument/signatureHelp") then
                        vim.keymap.set("n", "gK", function() vim.lsp.buf.signature_help() end, { buffer = bufnr, desc = "Signature help", silent = true })
                    end

                    if client.supports_method("workspace/symbol") then
                        vim.keymap.set("n", "<leader>lg", function() vim.lsp.buf.workspace_symbol() end, { buffer = bufnr, desc = "Search workspace symbols", silent = true })
                    end

                    if client.supports_method("textDocument/semanticTokens/full") and vim.lsp.semantic_tokens then
                        vim.b.semantic_tokens_enabled = true
                        if vim.b.semantic_tokens_enabled then
                            vim.keymap.set("n", "<leader>lts", function()
                                vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
                                local toggled = false
                                for _, client in ipairs(vim.lsp.get_active_clients { bufnr = bufnr }) do
                                    if client.server_capabilities.semanticTokensProvider then
                                        vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and "start" or "stop"](bufnr, client.id)
                                        toggled = true
                                    end
                                end
                                if toggled then
                                    vim.notify(string.format("Lsp Semantic Highlighting: %s", bool2str(vim.b[bufnr].semantic_tokens_enabled)), vim.log.levels.INFO, { title = "Buffer" })
                                end
                            end, { buffer = bufnr, desc = "Toggle LSP semantic highlight (buffer)", silent = true })
                        else
                            client.server_capabilities.semanticTokensProvider = nil
                        end
                    end
                end,
                desc = "Lsp setting",
                group = vim.api.nvim_create_augroup("LspSetting", { clear = true }),
            })
        end,
        dependencies = {
            {
                "folke/neodev.nvim",
                opts = {},
            },

            {
                "kosayoda/nvim-lightbulb",
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
                dependencies = {
                    "williamboman/mason.nvim",
                },
                opts = function()
                    local lspconfig = require("lspconfig")

                    local default_config = {
                        capabilities = vim.tbl_deep_extend(
                            "force",
                            {},
                            vim.lsp.protocol.make_client_capabilities(),
                            require("cmp_nvim_lsp").default_capabilities(),
                            {}
                        ),
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

                    return {
                        ensure_installed = variables.lsp_list,
                        automatic_installation = true,
                        handlers = handlers,
                    }
                end,
            },
        },
        enabled = not variables.is_vscode,
        event = {
            "User LspFile",
        },
    },

    -- {
    --     "stevearc/aerial.nvim",
    --     cmd = {
    --         "AerialToggle",
    --         "AerialOpen",
    --         "AerialOpenAll",
    --         "AerialClose",
    --         "AerialCloseAll",
    --         "AerialNext",
    --         "AerialPrev",
    --         "AerialGo",
    --         "AerialInfo",
    --         "AerialNavToggle",
    --         "AerialNavOpen",
    --         "AerialNavClose",
    --     },
    --     dependencies = {
    --         "nvim-treesitter/nvim-treesitter",
    --         "nvim-tree/nvim-web-devicons",
    --     },
    --     enabled = not variables.is_vscode,
    --     opts = {
    --         keymaps = {
    --             -- ["?"] = "actions.show_help",
    --             -- ["g?"] = "actions.show_help",
    --             -- ["<CR>"] = "actions.jump",
    --             ["l"] = "actions.jump",
    --             -- ["<2-LeftMouse>"] = "actions.jump",
    --             -- ["<C-v>"] = "actions.jump_vsplit",
    --             -- ["<C-s>"] = "actions.jump_split",
    --             ["<C-v>"] = false,
    --             ["<C-s>"] = false,
    --             ["V"] = "actions.jump_vsplit",
    --             ["v"] = "actions.jump_split",
    --             -- ["p"] = "actions.scroll",
    --             -- ["<C-j>"] = "actions.down_and_scroll",
    --             -- ["<C-k>"] = "actions.up_and_scroll",
    --             ["<C-j>"] = false,
    --             ["<C-k>"] = false,
    --             ["J"] = "actions.down_and_scroll",
    --             ["K"] = "actions.up_and_scroll",
    --             -- ["{"] = "actions.prev",
    --             -- ["}"] = "actions.next",
    --             -- ["[["] = "actions.prev_up",
    --             ["h"] = "actions.prev_up",
    --             -- ["]]"] = "actions.next_up",
    --             -- ["q"] = "actions.close",
    --             -- ["o"] = "actions.tree_toggle",
    --             -- ["za"] = "actions.tree_toggle",
    --             -- ["O"] = "actions.tree_toggle_recursive",
    --             -- ["zA"] = "actions.tree_toggle_recursive",
    --             -- ["l"] = "actions.tree_open",
    --             -- ["zo"] = "actions.tree_open",
    --             -- ["L"] = false,
    --             -- ["zO"] = "actions.tree_open_recursive",
    --             -- ["h"] = "actions.tree_close",
    --             -- ["zc"] = "actions.tree_close",
    --             -- ["H"] = "actions.tree_close_recursive",
    --             ["H"] = false,
    --             -- ["zC"] = "actions.tree_close_recursive",
    --             -- ["zr"] = "actions.tree_increase_fold_level",
    --             -- ["zR"] = "actions.tree_open_all",
    --             -- ["zm"] = "actions.tree_decrease_fold_level",
    --             -- ["zM"] = "actions.tree_close_all",
    --             -- ["zx"] = "actions.tree_sync_folds",
    --             -- ["zX"] = "actions.tree_sync_folds",
    --         },
    --         highlight_on_hover = true,
    --         show_guides = true,
    --     },
    -- },

    {
        "williamboman/mason.nvim",
        build = function()
            vim.api.nvim_command("MasonUpdate")

            -- 更新所有已经安装的 mason package
            local function mason_notify(msg, type)
                vim.notify(msg, type, { title = "Mason" })
            end

            local registry_avail, registry = pcall(require, "mason-registry")
            if not registry_avail then
                vim.api.nvim_err_writeln("Unable to access mason registry")
                return
            end

            mason_notify("Checking for package updates...")
            registry.update(vim.schedule_wrap(function(success, updated_registries)
                if success then
                    local installed_pkgs = registry.get_installed_packages()
                    local running = #installed_pkgs
                    local no_pkgs = running == 0

                    if no_pkgs then
                        mason_notify("No updates available")
                    else
                        local updated = false
                        for _, pkg in ipairs(installed_pkgs) do
                            pkg:check_new_version(function(update_available, version)
                                if update_available then
                                    updated = true
                                    mason_notify(("Updating `%s` to %s"):format(pkg.name, version.latest_version))
                                    pkg:install():on("closed", function()
                                        running = running - 1
                                        if running == 0 then
                                            mason_notify("Update Complete")
                                        end
                                    end)
                                else
                                    running = running - 1
                                    if running == 0 then
                                        if updated then
                                            mason_notify("Update Complete")
                                        else
                                            mason_notify("No updates available")
                                        end
                                    end
                                end
                            end)
                        end
                    end
                else
                    mason_notify(("Failed to update registries: %s"):format(updated_registries), vim.log.levels.ERROR)
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
