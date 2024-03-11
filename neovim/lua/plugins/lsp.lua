local environment = require("utils.environment")
local icons = require("utils.icons")
local keymap = require("utils.keymap")
local lsp = require("utils.lsp")
local null_ls = require("utils.null_ls")
local path = require("utils.path")
local utils = require("utils")

return {
    {
        "dnlhc/glance.nvim",
        cmd = {
            "Glance references",
            "Glance definitions",
            "Glance type_definitions",
            "Glance implementations",
        },
        enabled = not environment.is_vscode,
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
                            local target_fname = vim.uri_to_fname(target_uri:lower())
                            local curr_uri = vim.uri_from_bufnr(0)
                            local curr_fname = vim.uri_to_fname(curr_uri:lower())

                            if target_fname == curr_fname then
                                jump(results[1])
                            else
                                vim.api.nvim_command("tab sbuffer")
                                jump(results[1])
                            end

                            vim.cmd("normal! zt")
                        else
                            open(results)
                        end
                    end,
                    after_close = function()
                        vim.cmd("normal! zt")
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
        enabled = not environment.is_vscode,
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
            use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
        },
    },

    {
        "j-hui/fidget.nvim",
        enabled = not environment.is_vscode,
        event = {
            "LspAttach",
        },
        opts = {
            notification = {
                window = {
                    winblend = 0,
                },
            },
            integration = {
                ["nvim-tree"] = {
                    enable = false,
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
                        function() end, -- disables automatic setup of all null-ls sources
                    }
                    for null_ls_builtin, setup in pairs(null_ls.null_ls_builtins(require("null-ls"))) do
                        handlers[null_ls_builtin] = setup
                    end

                    return {
                        ensure_installed = null_ls.null_ls_builtins_list,
                        automatic_installation = true,
                        handlers = handlers,
                    }
                end,
            },

            "nvim-lua/plenary.nvim",
        },
        enabled = not environment.is_vscode,
        event = {
            "User LspFile",
        },
        opts = {
            border = "rounded",
        },
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

            require("lspconfig.ui.windows").default_options.border = "rounded"

            -- Customizing how diagnostics are displayed
            vim.diagnostic.config({
                virtual_text = {
                    source = "if_many",
                    spacing = 4,
                    prefix = icons.dap.Breakpoint,
                },
                update_in_insert = true,
                severity_sort = true,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local buf = args.buf

                    local is_which_key_available, which_key = pcall(require, "which-key")
                    if is_which_key_available then
                        which_key.register({
                            mode = "n",
                            ["<leader>l"] = {
                                name = "+lsp",
                            },
                            buffer = buf,
                        })
                        which_key.register({
                            mode = "n",
                            ["<leader>lt"] = {
                                name = "+lsp toggle",
                            },
                            buffer = buf,
                        })
                    end

                    local function has_capability(capability, filter)
                        for _, lsp_client in ipairs(vim.lsp.get_clients(filter)) do
                            if lsp_client.supports_method(capability) then
                                return true
                            end
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

                    if vim.g.lsp_enabled == nil then
                        vim.g.lsp_enabled = true
                    end

                    local function lsp_stop_command()
                        vim.schedule(function() vim.api.nvim_command("LspStop") end)
                    end

                    local function lsp_stop()
                        if vim.b[buf].lsp_enabled ~= nil then
                            if not vim.b[buf].lsp_enabled then
                                lsp_stop_command()
                            end
                        else
                            if not vim.g.lsp_enabled then
                                lsp_stop_command()
                            end
                        end
                    end

                    lsp_stop()
                    add_buffer_autocmd("lsp_stop", buf, {
                        callback = function()
                            lsp_stop()
                        end,
                        desc = "Stop LSP",
                        events = "BufReadPost",
                    })

                    vim.keymap.set("n", "<leader>ltl", function()
                        utils.toggle_global_setting("lsp_enabled", function(global_enabled, prev_enabled, enabled)
                            if not global_enabled then
                                vim.lsp.stop_client(vim.lsp.get_clients())
                            end
                            if (not prev_enabled or not global_enabled) and enabled then
                                utils.refresh_buf(buf)
                            end
                        end)
                    end, { buffer = buf, desc = "Toggle LSP", silent = true })
                    vim.keymap.set("n", "<leader>ltL", function()
                        utils.toggle_buffer_setting("lsp_enabled", function(prev_enabled, enabled)
                            if not enabled then
                                lsp_stop_command()
                            end
                            if not prev_enabled and enabled then
                                utils.refresh_buf(buf)
                            end
                        end)
                    end, { buffer = buf, desc = "Toggle LSP (buffer)", silent = true })

                    vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end, { buffer = buf, desc = "Hover diagnostics", silent = true })
                    if not utils.is_available("trouble.nvim") then
                        vim.keymap.set("n", "<s-f8>", function() vim.diagnostic.goto_prev() end, { buffer = buf, desc = "Previous diagnostic", silent = true })
                        vim.keymap.set("n", "<f8>", function() vim.diagnostic.goto_next() end, { buffer = buf, desc = "Next diagnostic", silent = true })
                    end

                    vim.keymap.set("n", "<leader>li", function() vim.api.nvim_command("LspInfo") end, { buffer = buf, desc = "LSP information", silent = true })

                    if utils.is_available("none-ls.nvim") then
                        vim.keymap.set("n", "<leader>lI", function() vim.api.nvim_command("NullLsInfo") end, { buffer = buf, desc = "Null-ls information", silent = true })
                    end

                    if client.supports_method("textDocument/codeAction") then
                        vim.keymap.set({ "n", "x" }, keymap["<c-;>"], function() vim.lsp.buf.code_action() end, { buffer = buf, desc = "LSP code action", silent = true })
                    end

                    if client.supports_method("textDocument/codeLens") then
                        vim.b.codelens_enabled = nil
                        if vim.g.codelens_enabled == nil then
                            vim.g.codelens_enabled = true
                        end

                        add_buffer_autocmd("lsp_codelens_refresh", buf, {
                            callback = function()
                                if not has_capability("textDocument/codeLens", { bufnr = buf }) then
                                    del_buffer_autocmd("lsp_codelens_refresh", buf)
                                    return
                                end
                                if vim.b[buf].codelens_enabled ~= nil then
                                    if vim.b[buf].codelens_enabled then
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

                        vim.keymap.set("n", "<leader>ltc", function()
                            utils.toggle_global_setting("codelens_enabled", function(global_enabled, prev_enabled, enabled)
                                if not enabled then
                                    vim.lsp.codelens.clear()
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP codelens", silent = true })
                        vim.keymap.set("n", "<leader>ltC", function()
                            utils.toggle_buffer_setting("codelens_enabled", function(prev_enabled, enabled)
                                if not enabled then
                                    vim.lsp.codelens.clear()
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP codelens (buffer)", silent = true })

                        vim.keymap.set("n", "<leader>lc", function() vim.lsp.codelens.refresh() end, { buffer = buf, desc = "LSP CodeLens refresh", silent = true })
                        vim.keymap.set("n", "<leader>lC", function() vim.lsp.codelens.run() end, { buffer = buf, desc = "LSP CodeLens run", silent = true })
                    end

                    if client.supports_method("textDocument/declaration") then
                        vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, { buffer = buf, desc = "Declaration of current symbol", silent = true })
                    end

                    if not utils.is_available("glance.nvim") then
                        if client.supports_method("textDocument/definition") then
                            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { buffer = buf, desc = "Show the definition of current symbol", silent = true })
                        end

                        if client.supports_method("textDocument/implementation") then
                            vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, { buffer = buf, desc = "Implementation of current symbol", silent = true })
                        end

                        if client.supports_method("textDocument/typeDefinition") then
                            vim.keymap.set("n", "gy", function() vim.lsp.buf.type_definition() end, { buffer = buf, desc = "Definition of current type", silent = true })
                        end

                        if client.supports_method("textDocument/references") then
                            vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, { buffer = buf, desc = "References of current symbol", silent = true })
                        end
                    end

                    if client.supports_method("textDocument/formatting") then
                        -- Gets all lsp clients that support formatting
                        -- and have not disabled it in their client config
                        local function supports_format(client)
                            if
                                client.config
                                and client.config.capabilities
                                and client.config.capabilities.documentFormattingProvider == false
                            then
                                return false
                            end
                            return client.supports_method("textDocument/formatting") or client.supports_method("textDocument/rangeFormatting")
                        end

                        -- When a null-ls formatter is available for the current filetype,
                        -- only null-ls formatters are returned.
                        local function get_formatters(bufnr)
                            local formatters = {}

                            local ft = vim.bo[bufnr].filetype
                            -- check if we have any null-ls formatters for the current filetype
                            local null_ls = package.loaded["null-ls"] and require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") or {}

                            local clients = vim.lsp.get_clients({ bufnr = bufnr })
                            if #null_ls > 0 then
                                for _, client in ipairs(clients) do
                                    if supports_format(client) and client.name == "null-ls" then
                                        formatters[#formatters + 1] = client
                                    end
                                end
                            else
                                for _, client in ipairs(clients) do
                                    if supports_format(client) then
                                        formatters[#formatters + 1] = client
                                    end
                                end
                            end

                            return formatters
                        end

                        -- 若 lsp 和 null-ls 都有 formatter，则优先使用 null-ls 的 formatter
                        local format = function()
                            local formatters = get_formatters(args.buf)
                            local client_ids = vim.tbl_map(function(client)
                                return client.id
                            end, formatters)

                            if #client_ids == 0 then
                                return
                            end

                            vim.lsp.buf.format({
                                bufnr = args.buf,
                                filter = function(client)
                                    return vim.tbl_contains(client_ids, client.id)
                                end,
                            })
                        end

                        vim.keymap.set({ "n", "x" }, "<leader>f", format, { buffer = buf, desc = "Format buffer", silent = true })

                        if vim.g.autoformat_enabled == nil then
                            vim.g.autoformat_enabled = false
                        end

                        add_buffer_autocmd("lsp_auto_format", buf, {
                            callback = function()
                                if not has_capability("textDocument/formatting", { bufnr = buf }) then
                                    del_buffer_autocmd("lsp_auto_format", buf)
                                    return
                                end
                                if vim.b[buf].autoformat_enabled ~= nil then
                                    if vim.b[buf].autoformat_enabled then
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

                        vim.keymap.set("n", "<leader>ltf", function() utils.toggle_global_setting("autoformat_enabled", function(global_enabled, prev_enabled, enabled) end) end, { buffer = buf, desc = "Toggle autoformatting", silent = true })
                        vim.keymap.set("n", "<leader>ltF", function() utils.toggle_buffer_setting("autoformat_enabled", function(prev_enabled, enabled) end) end, { buffer = buf, desc = "Toggle autoformatting (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/documentHighlight") then
                        add_buffer_autocmd("lsp_document_highlight", buf, {
                            {
                                callback = function()
                                    if not has_capability("textDocument/documentHighlight", { bufnr = buf }) then
                                        del_buffer_autocmd("lsp_document_highlight", buf)
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
                        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { buffer = buf, desc = "Hover symbol details", silent = true })
                    end

                    if client.supports_method("textDocument/inlayHint") then
                        if vim.g.inlay_hints_enabled == nil then
                            vim.g.inlay_hints_enabled = true
                        end

                        if vim.b[buf].inlay_hints_enabled ~= nil then
                            if vim.b[buf].inlay_hints_enabled then
                                vim.lsp.inlay_hint.enable(buf, true)
                            end
                        else
                            if vim.g.inlay_hints_enabled then
                                vim.lsp.inlay_hint.enable(buf, true)
                            end
                        end

                        vim.keymap.set("n", "<leader>lti", function()
                            utils.toggle_global_setting("inlay_hints_enabled", function(global_enabled, prev_enabled, enabled)
                                if enabled ~= vim.lsp.inlay_hint.get({ bufnr = buf }) then
                                    vim.lsp.inlay_hint.enable(buf, enabled)
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP inlay hints", silent = true })
                        vim.keymap.set("n", "<leader>ltI", function()
                            utils.toggle_buffer_setting("inlay_hints_enabled", function(prev_enabled, enabled)
                                if enabled ~= vim.lsp.inlay_hint.get({ bufnr = buf }) then
                                    vim.lsp.inlay_hint.enable(buf, enabled)
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP inlay hints (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/rename") then
                        vim.keymap.set("n", "<f2>", function() vim.lsp.buf.rename() end, { buffer = buf, desc = "Rename current symbol", silent = true })
                    end

                    if client.supports_method("textDocument/signatureHelp") then
                        vim.keymap.set("n", "gK", function() vim.lsp.buf.signature_help() end, { buffer = buf, desc = "Signature help", silent = true })
                    end

                    if client.supports_method("workspace/symbol") then
                        vim.keymap.set("n", "<leader>lg", function() vim.lsp.buf.workspace_symbol() end, { buffer = buf, desc = "Search workspace symbols", silent = true })
                    end

                    if client.supports_method("textDocument/semanticTokens/full") and vim.lsp.semantic_tokens then
                        if vim.g.semantic_tokens_enabled == nil then
                            vim.g.semantic_tokens_enabled = true
                        end

                        local toggle_semantic_tokens = function(enabled)
                            for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
                                if client.server_capabilities.semanticTokensProvider then
                                    vim.lsp.semantic_tokens[enabled and "start" or "stop"](buf, client.id)
                                end
                            end
                        end

                        vim.keymap.set("n", "<leader>lts", function()
                            utils.toggle_global_setting("semantic_tokens_enabled", function(global_enabled, prev_enabled, enabled)
                                if enabled ~= prev_enabled then
                                    toggle_semantic_tokens(enabled)
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP semantic highlight", silent = true })
                        vim.keymap.set("n", "<leader>ltS", function()
                            utils.toggle_buffer_setting("semantic_tokens_enabled", function(prev_enabled, enabled)
                                if enabled ~= prev_enabled then
                                    toggle_semantic_tokens(enabled)
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP semantic highlight (buffer)", silent = true })
                    end
                end,
                desc = "Lsp config",
                group = vim.api.nvim_create_augroup("LspConfig", { clear = true }),
            })
        end,
        dependencies = {
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

                    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
                    local cmp_nvim_lsp_capabilities = has_cmp and cmp_nvim_lsp.default_capabilities() or {}
                    local default_config = {
                        capabilities = vim.tbl_deep_extend(
                            "force",
                            {},
                            vim.lsp.protocol.make_client_capabilities(),
                            cmp_nvim_lsp_capabilities,
                            {}
                        ),
                    }

                    local handlers = {
                        -- The first entry (without a key) will be the default handler
                        -- and will be called for each installed server that doesn't have
                        -- a dedicated handler.
                        -- function(server_name)
                        --     lspconfig[server_name].setup(default_config)
                        -- end,
                    }
                    for lsp_server, setup in pairs(lsp.lsp(lspconfig, default_config)) do
                        handlers[lsp_server] = setup
                    end

                    return {
                        ensure_installed = lsp.lsp_list,
                        automatic_installation = true,
                        handlers = handlers,
                    }
                end,
            },
        },
        enabled = not environment.is_vscode,
        event = {
            "User LspFile",
        },
        init = function()
            -- Change diagnostic symbols in the sign column (gutter)
            for type, icon in pairs(icons.diagnostics) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end
        end,
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
    --     enabled = not environment.is_vscode,
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
        build = {
            ":MasonUpdate",
        },
        cmd = {
            "Mason",
            "MasonUpdate",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
        },
        config = function(_, opts)
            require("mason").setup(opts)

            -- 更新所有已经安装的 mason package
            local function mason_notify(msg, type)
                vim.notify(msg, type, { title = "Mason" })
            end

            local registry_avail, registry = pcall(require, "mason-registry")
            if not registry_avail then
                vim.api.nvim_err_writeln("Unable to access mason registry")
                return
            end

            -- mason_notify("Checking for package updates...")
            registry.update(vim.schedule_wrap(function(success, updated_registries)
                if success then
                    local installed_pkgs = registry.get_installed_packages()
                    local running = #installed_pkgs
                    local no_pkgs = running == 0

                    if no_pkgs then
                        -- mason_notify("No updates available")
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
                                            -- mason_notify("No updates available")
                                        end
                                    end
                                end
                            end)
                        end
                    end
                    -- else
                    --     mason_notify(("Failed to update registries: %s"):format(updated_registries), vim.log.levels.ERROR)
                end
            end))
        end,
        enabled = not environment.is_vscode,
        keys = {
            { "<leader>lm", function() vim.api.nvim_command("Mason") end, desc = "Mason information", mode = "n" },
        },
        opts = {
            -- The directory in which to install packages.
            install_root_dir = path.mason_install_root_path,
            -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
            -- debugging issues with package installations.
            log_level = vim.log.levels.OFF,
            ui = {
                border = "rounded",
            },
        },
    },

}
