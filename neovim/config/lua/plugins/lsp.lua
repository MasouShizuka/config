local environment = require("utils.environment")
local format = require("utils.format")
local icons = require("utils.icons")
local keymap = require("utils.keymap")
local lint = require("utils.lint")
local lsp = require("utils.lsp")
local path = require("utils.path")
local utils = require("utils")

return {
    {
        "aznhe21/actions-preview.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        enabled = not environment.is_vscode,
        lazy = true,
        opts = {
            telescope = {},
        },
    },

    {
        "folke/trouble.nvim",
        cmd = {
            "Trouble",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        init = function()
            local is_wk_available, wk = pcall(require, "which-key")
            if is_wk_available then
                wk.add({
                    { "<leader>x", group = "trouble", mode = "n" },
                })
            end
        end,
        keys = {
            { "<leader>xx", function() require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } }) end, desc = "Buffer Diagnostics (Trouble)",                 mode = "n" },
            { "<leader>xw", function() require("trouble").toggle({ mode = "diagnostics" }) end,                       desc = "Diagnostics (Trouble)",                        mode = "n" },
            { "<leader>xs", function() require("trouble").toggle({ mode = "symbols", focus = false }) end,            desc = "Symbols (Trouble)",                            mode = "n" },
            { "<leader>xl", function() require("trouble").toggle({ mode = "lsp", focus = false }) end,                desc = "LSP Definitions / References / ... (Trouble)", mode = "n" },
            { "<leader>xL", function() require("trouble").toggle({ mode = "loclist" }) end,                           desc = "Location List (Trouble)",                      mode = "n" },
            { "<leader>xq", function() require("trouble").toggle({ mode = "qflist" }) end,                            desc = "Quickfix List (Trouble)",                      mode = "n" },
            {
                "gd",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_definitions" })
                    utils.defer(function() view.win:focus() end, 200, false)
                end,
                desc = "LSP Definitions (Trouble)",
                mode = "n",
            },
            {
                "gD",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_declarations" })
                    utils.defer(function() view.win:focus() end, 200, false)
                end,
                desc = "LSP Declarations (Trouble)",
                mode = "n",
            },
            {
                "gi",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_implementations" })
                    utils.defer(function() view.win:focus() end, 200, false)
                end,
                desc = "LSP Implementations (Trouble)",
                mode = "n",
            },
            {
                "gr",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_references" })
                    utils.defer(function() view.win:focus() end, 200, false)
                end,
                desc = "LSP References (Trouble)",
                mode = "n",
            },
            {
                "gy",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_type_definitions" })
                    utils.defer(function() view.win:focus() end, 200, false)
                end,
                desc = "LSP Type Definitions (Trouble)",
                mode = "n",
            },
            {
                "<f8>",
                function()
                    if not require("trouble").is_open() then
                        require("trouble").open({ mode = "diagnostics" })
                    else
                        require("trouble").next({ jump = true })
                    end
                end,
                desc = "Next diagnostic",
                mode = "n",
            },
            {
                "<s-f8>",
                function()
                    if not require("trouble").is_open() then
                        require("trouble").open({ mode = "diagnostics" })
                    else
                        require("trouble").prev({ jump = true })
                    end
                end,
                desc = "Previous diagnostic",
                mode = "n",
            },
        },
        opts = {
            -- Key mappings can be set to the name of a builtin action,
            -- or you can define your own custom action.
            ---@type table<string, string|trouble.Action>
            keys = {
                -- ["?"] = "help",
                -- r = "refresh",
                -- R = "toggle_refresh",
                -- q = "close",
                -- o = "jump_close",
                -- ["<esc>"] = "cancel",
                -- ["<cr>"] = "jump",
                l = "jump",
                -- ["<2-leftmouse>"] = "jump",
                -- ["<c-s>"] = "jump_split",
                -- ["<c-v>"] = "jump_vsplit",
                V = "jump_split",
                v = "jump_vsplit",
                t = function(self, ctx)
                    if ctx.item then
                        vim.api.nvim_command("tab sbuffer")
                        self:jump(ctx.item)
                    end
                end,
                -- -- go down to next item (accepts count)
                -- -- j = "next",
                -- ["}"] = "next",
                -- ["]]"] = "next",
                -- -- go up to prev item (accepts count)
                -- -- k = "prev",
                -- ["{"] = "prev",
                -- ["[["] = "prev",
                -- i = "inspect",
                -- p = "preview",
                -- P = "toggle_preview",
                -- zo = "fold_open",
                -- zO = "fold_open_recursive",
                -- zc = "fold_close",
                -- zC = "fold_close_recursive",
                -- za = "fold_toggle",
                -- zA = "fold_toggle_recursive",
                -- zm = "fold_more",
                -- zM = "fold_close_all",
                -- zr = "fold_reduce",
                -- zR = "fold_open_all",
                -- zx = "fold_update",
                -- zX = "fold_update_all",
                -- zn = "fold_disable",
                -- zN = "fold_enable",
                -- zi = "fold_toggle_enable",
                -- gb = { -- example of a custom action that toggles the active view filter
                --     action = function(view)
                --         view.state.filter_buffer = not view.state.filter_buffer
                --         view:filter(view.state.filter_buffer and { buf = 0 } or nil)
                --     end,
                --     desc = "Toggle Current Buffer Filter",
                -- },
                -- s = { -- example of a custom action that toggles the severity
                --     action = function(view)
                --         local f = view:get_filter("severity")
                --         local severity = ((f and f.filter.severity or 0) + 1) % 5
                --         view:filter({ severity = severity }, {
                --             id = "severity",
                --             template = "{hl:Title}Filter:{hl} {severity}",
                --             del = severity == 0,
                --         })
                --     end,
                --     desc = "Toggle Severity Filter",
                -- },
            },
            ---@type table<string, trouble.Mode>
            modes = {
                lsp_preview = {
                    mode = "lsp_base",
                    params = {
                        include_current = true,
                    },
                    restore = false,
                    win = {
                        type = "float",
                        realtive = "editor",
                        size = { width = 0.5, height = 0.5 },
                        position = { 0.5, 1 },
                        border = "rounded",
                        title_pos = "center",
                    },
                    preview = {
                        type = "float",
                        realtive = "editor",
                        size = { width = 0.5, height = 0.5 },
                        position = { 0.5, 0 },
                        border = "rounded",
                        title = "Preview",
                        title_pos = "center",
                        wo = {
                            number = true,
                            statuscolumn = "%l",
                        },
                    },
                    keys = {
                        ["<esc>"] = "close",
                        l = "jump_close",
                        V = function(self, ctx)
                            if ctx.item then
                                self:jump(ctx.item, { split = true })
                                self:close()
                            end
                        end,
                        v = function(self, ctx)
                            if ctx.item then
                                self:jump(ctx.item, { vsplit = true })
                                self:close()
                            end
                        end,
                        t = function(self, ctx)
                            if ctx.item then
                                self:close()
                                vim.api.nvim_command("tab sbuffer " .. self:main().buf)
                                self:jump(ctx.item)
                            end
                        end,
                    },
                },
                lsp_definitions = {
                    mode = "lsp_preview",
                    win = {
                        title = "Definitions",
                    },
                },
                lsp_declarations = {
                    mode = "lsp_preview",
                    win = {
                        title = "Declarations",
                    },
                },
                lsp_implementations = {
                    mode = "lsp_preview",
                    win = {
                        title = "Implementations",
                    },
                },
                lsp_references = {
                    mode = "lsp_preview",
                    win = {
                        title = "References",
                    },
                },
                lsp_type_definitions = {
                    mode = "lsp_preview",
                    win = {
                        title = "Type Definitions",
                    },
                },
            },
        },
    },

    {
        "mfussenegger/nvim-lint",
        config = function(_, opt)
            local nvim_lint = require("lint")

            for linter, config in pairs(lint.lint) do
                if not config then
                    goto continue
                end

                for key, value in pairs(config) do
                    nvim_lint.linters[linter][key] = value
                end

                ::continue::
            end

            nvim_lint.linters_by_ft = lint.linters_by_ft

            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
                callback = function(args)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })

                    -- Use nvim-lint's logic first:
                    -- * checks if linters exist for the full filetype first
                    -- * otherwise will split filetype by "." and add all those linters
                    -- * this differs from conform.nvim which only uses the first filetype that has a formatter
                    local names = nvim_lint._resolve_linter_by_ft(ft)

                    -- Create a copy of the names table to avoid modifying the original.
                    names = vim.list_extend({}, names)

                    -- Add fallback linters.
                    if #names == 0 then
                        vim.list_extend(names, nvim_lint.linters_by_ft["_"] or {})
                    end

                    -- Add global linters.
                    vim.list_extend(names, nvim_lint.linters_by_ft["*"] or {})

                    -- Filter out linters that don't exist or don't match the condition.
                    local ctx = { filename = vim.api.nvim_buf_get_name(args.buf) }
                    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
                    names = vim.tbl_filter(function(name)
                        local linter = nvim_lint.linters[name]
                        if not linter then
                            vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
                        end
                        return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
                    end, names)

                    -- Run linters.
                    if #names > 0 then
                        utils.defer(function()
                            if vim.api.nvim_get_current_buf() == args.buf then
                                nvim_lint.try_lint(names)
                            end
                        end, 100, false)
                    end
                end,
                desc = "Lint buffer",
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
            })
        end,
        enabled = not environment.is_vscode,
        ft = lint.lint_filetype_list,
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

                    local is_wk_available, wk = pcall(require, "which-key")
                    if is_wk_available then
                        wk.add({
                            {
                                buffer = args.buf,
                                mode = "n",
                                { "<leader>l",  group = "lsp" },
                                { "<leader>lt", group = "lsp toggle" },
                            },
                        })
                    end

                    if vim.g.lsp_enabled == nil then
                        vim.g.lsp_enabled = true
                    end

                    local function lsp_stop_command()
                        vim.schedule(function()
                            local servers_on_buffer = vim.lsp.get_clients({ bufnr = buf })
                            for _, client in ipairs(servers_on_buffer) do
                                if client.attached_buffers[buf] then
                                    client.stop()
                                end
                            end
                        end)
                    end

                    local function lsp_stop()
                        if not (vim.b[buf].lsp_enabled == nil and vim.g.lsp_enabled or vim.b[buf].lsp_enabled) then
                            lsp_stop_command()
                        end
                    end

                    lsp_stop()
                    vim.api.nvim_create_autocmd("BufReadPost", {
                        buffer = buf,
                        callback = function()
                            lsp_stop()
                        end,
                        desc = "Stop Lsp",
                        group = vim.api.nvim_create_augroup(string.format("LspStop%s", buf), { clear = true }),
                    })

                    vim.keymap.set("n", "<leader>ltl", function()
                        utils.toggle_global_setting("lsp_enabled", function(enabled, prev_enabled, global_enabled)
                            if not global_enabled then
                                vim.lsp.stop_client(vim.lsp.get_clients())
                            end
                            if (not prev_enabled or not global_enabled) and enabled then
                                utils.refresh_buf(buf)
                            end
                        end)
                    end, { buffer = buf, desc = "Toggle LSP", silent = true })
                    vim.keymap.set("n", "<leader>ltL", function()
                        utils.toggle_buffer_setting("lsp_enabled", function(enabled, prev_enabled)
                            if not enabled then
                                lsp_stop_command()
                            end
                            if not prev_enabled and enabled then
                                utils.refresh_buf(buf)
                            end
                        end)
                    end, { buffer = buf, desc = "Toggle LSP (buffer)", silent = true })

                    if client.supports_method("textDocument/codeAction") then
                        if utils.is_available("actions-preview.nvim") then
                            vim.keymap.set({ "n", "x" }, keymap["<c-;>"], function() require("actions-preview").code_actions() end, { buffer = buf, desc = "LSP code action", silent = true })
                        else
                            vim.keymap.set({ "n", "x" }, keymap["<c-;>"], function() vim.lsp.buf.code_action() end, { buffer = buf, desc = "LSP code action", silent = true })
                        end
                    end

                    if client.supports_method("textDocument/codeLens") then
                        if vim.g.codelens_enabled == nil then
                            vim.g.codelens_enabled = true
                        end

                        local function lsp_codelens_refresh()
                            if vim.b[buf].codelens_enabled == nil and vim.g.codelens_enabled or vim.b[buf].codelens_enabled then
                                vim.lsp.codelens.refresh({ bufnr = buf })
                            end
                        end

                        lsp_codelens_refresh()
                        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                            buffer = buf,
                            callback = function()
                                lsp_codelens_refresh()
                            end,
                            desc = "Refresh codelens",
                            group = vim.api.nvim_create_augroup(string.format("LspCodelensRefresh%s", buf), { clear = true }),
                        })

                        vim.keymap.set("n", "<leader>ltc", function()
                            utils.toggle_global_setting("codelens_enabled", function(enabled, prev_enabled, global_enabled)
                                if not enabled then
                                    vim.lsp.codelens.clear()
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP codelens", silent = true })
                        vim.keymap.set("n", "<leader>ltC", function()
                            utils.toggle_buffer_setting("codelens_enabled", function(enabled, prev_enabled)
                                if not enabled then
                                    vim.lsp.codelens.clear()
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP codelens (buffer)", silent = true })

                        vim.keymap.set("n", "<leader>lc", function() vim.lsp.codelens.refresh({ bufnr = buf }) end, { buffer = buf, desc = "LSP CodeLens refresh", silent = true })
                        vim.keymap.set("n", "<leader>lC", function() vim.lsp.codelens.run() end, { buffer = buf, desc = "LSP CodeLens run", silent = true })
                    end

                    if not utils.is_available("trouble.nvim") then
                        if client.supports_method("textDocument/definition") then
                            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { buffer = buf, desc = "Show the definition of current symbol", silent = true })
                        end

                        if client.supports_method("textDocument/declaration") then
                            vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, { buffer = buf, desc = "Declaration of current symbol", silent = true })
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

                    if client.supports_method("textDocument/documentHighlight") then
                        local augroup = vim.api.nvim_create_augroup(string.format("LspDocumentHighlight%s", buf), { clear = true })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = buf,
                            callback = function()
                                vim.lsp.buf.document_highlight()
                            end,
                            desc = "Highlight references when cursor holds",
                            group = augroup,
                        })
                        vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "CursorMovedI" }, {
                            buffer = buf,
                            callback = function()
                                vim.lsp.buf.clear_references()
                            end,
                            desc = "Clear references when cursor moves",
                            group = augroup,
                        })
                    end

                    if
                        client.supports_method("textDocument/formatting") or
                        client.supports_method("textDocument/rangeFormatting") or
                        utils.is_available("conform.nvim")
                    then
                        local buf_format
                        if utils.is_available("conform.nvim") then
                            buf_format = function()
                                require("conform").format({
                                    timeout_ms = 5000,
                                    bufnr = buf,
                                    lsp_format = "fallback",
                                })
                            end
                        else
                            buf_format = function()
                                vim.lsp.buf.format({
                                    timeout_ms = 5000,
                                    bufnr = buf,
                                })
                            end
                        end

                        vim.keymap.set({ "n", "x" }, "<leader>f", buf_format, { buffer = buf, desc = "Format buffer", silent = true })

                        if vim.g.autoformat_enabled == nil then
                            vim.g.autoformat_enabled = false
                        end

                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = buf,
                            callback = function()
                                if vim.b[buf].autoformat_enabled == nil and vim.g.autoformat_enabled or vim.b[buf].autoformat_enabled then
                                    buf_format()
                                end
                            end,
                            desc = "Autoformat on save",
                            group = vim.api.nvim_create_augroup(string.format("LspAutoFormat%s", buf), { clear = true }),
                        })

                        vim.keymap.set("n", "<leader>ltf", function() utils.toggle_global_setting("autoformat_enabled", function(enabled, prev_enabled, global_enabled) end) end, { buffer = buf, desc = "Toggle autoformatting", silent = true })
                        vim.keymap.set("n", "<leader>ltF", function() utils.toggle_buffer_setting("autoformat_enabled", function(enabled, prev_enabled) end) end, { buffer = buf, desc = "Toggle autoformatting (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/hover") then
                        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { buffer = buf, desc = "Hover symbol details", silent = true })
                    end

                    if client.supports_method("textDocument/inlayHint") then
                        if vim.g.inlay_hints_enabled == nil then
                            vim.g.inlay_hints_enabled = true
                        end

                        if vim.b[buf].inlay_hints_enabled == nil and vim.g.inlay_hints_enabled or vim.b[buf].inlay_hints_enabled then
                            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
                        end

                        vim.keymap.set("n", "<leader>lti", function()
                            utils.toggle_global_setting("inlay_hints_enabled", function(enabled, prev_enabled, global_enabled)
                                if enabled ~= vim.lsp.inlay_hint.get({ bufnr = buf }) then
                                    vim.lsp.inlay_hint.enable(enabled, { bufnr = buf })
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP inlay hints", silent = true })
                        vim.keymap.set("n", "<leader>ltI", function()
                            utils.toggle_buffer_setting("inlay_hints_enabled", function(enabled, prev_enabled)
                                if enabled ~= vim.lsp.inlay_hint.get({ bufnr = buf }) then
                                    vim.lsp.inlay_hint.enable(enabled, { bufnr = buf })
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP inlay hints (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/rename") then
                        vim.keymap.set("n", "<f2>", function() vim.lsp.buf.rename() end, { buffer = buf, desc = "Rename current symbol", silent = true })
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
                            utils.toggle_global_setting("semantic_tokens_enabled", function(enabled, prev_enabled, global_enabled)
                                if enabled ~= prev_enabled then
                                    toggle_semantic_tokens(enabled)
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP semantic highlight", silent = true })
                        vim.keymap.set("n", "<leader>ltS", function()
                            utils.toggle_buffer_setting("semantic_tokens_enabled", function(enabled, prev_enabled)
                                if enabled ~= prev_enabled then
                                    toggle_semantic_tokens(enabled)
                                end
                            end)
                        end, { buffer = buf, desc = "Toggle LSP semantic highlight (buffer)", silent = true })
                    end

                    if client.supports_method("textDocument/signatureHelp") then
                        vim.keymap.set("n", "gK", function() vim.lsp.buf.signature_help() end, { buffer = buf, desc = "Signature help", silent = true })
                    end

                    if client.supports_method("workspace/symbol") then
                        vim.keymap.set("n", "<leader>lg", function() vim.lsp.buf.workspace_symbol() end, { buffer = buf, desc = "Search workspace symbols", silent = true })
                    end

                    vim.keymap.set("n", "<leader>li", function() vim.api.nvim_command("LspInfo") end, { buffer = buf, desc = "LSP information", silent = true })

                    vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end, { buffer = buf, desc = "Hover diagnostics", silent = true })
                    if not utils.is_available("trouble.nvim") then
                        vim.keymap.set("n", "<s-f8>", function() vim.diagnostic.goto_prev() end, { buffer = buf, desc = "Previous diagnostic", silent = true })
                        vim.keymap.set("n", "<f8>", function() vim.diagnostic.goto_next() end, { buffer = buf, desc = "Next diagnostic", silent = true })
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

                    local config = {}
                    if utils.is_available("nvim-ufo") then
                        config = {
                            textDocument = {
                                foldingRange = {
                                    dynamicRegistration = false,
                                    lineFoldingOnly = true,
                                },
                            },
                        }
                    end

                    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
                    local cmp_nvim_lsp_capabilities = has_cmp and cmp_nvim_lsp.default_capabilities() or {}

                    local default_config = {
                        capabilities = vim.tbl_deep_extend(
                            "force",
                            config,
                            vim.lsp.protocol.make_client_capabilities(),
                            cmp_nvim_lsp_capabilities
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
        ft = lsp.lsp_filetype_list,
        init = function()
            -- Change diagnostic symbols in the sign column (gutter)
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
                        [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
                        [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
                        [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
                    },
                },
            })
        end,
    },

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
        dependencies = {
            {
                "WhoIsSethDaniel/mason-tool-installer.nvim",
                cmd = {
                    "MasonToolsInstall",
                    "MasonToolsInstallSync",
                    "MasonToolsUpdate",
                    "MasonToolsUpdateSync",
                    "MasonToolsClean",
                },
                config = function(_, opts)
                    local mason_tool_installer = require("mason-tool-installer")
                    mason_tool_installer.setup(opts)

                    mason_tool_installer.run_on_start()
                end,
                dependencies = {
                    "williamboman/mason.nvim",
                },
                enabled = not environment.is_vscode,
                opts = function()
                    return {
                        -- a list of all tools you want to ensure are installed upon
                        -- start
                        -- ensure_installed = format.format_list,
                        ensure_installed = utils.table_concat(format.format_list, lint.lint_list),

                        -- By default all integrations are enabled. If you turn on an integration
                        -- and you have the required module(s) installed this means you can use
                        -- alternative names, supplied by the modules, for the thing that you want
                        -- to install. If you turn off the integration (by setting it to false) you
                        -- cannot use these alternative names. It also suppresses loading of those
                        -- module(s) (assuming any are installed) which is sometimes wanted when
                        -- doing lazy loading.
                        integrations = {
                            ["mason-lspconfig"] = false,
                            ["mason-null-ls"] = false,
                            ["mason-nvim-dap"] = false,
                        },
                    }
                end,
            },

        },
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
