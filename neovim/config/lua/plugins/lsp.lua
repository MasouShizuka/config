local environment = require("utils.environment")

return {
    {
        "aznhe21/actions-preview.nvim",
        cond = not environment.is_vscode and environment.lsp_enable,
        lazy = true,
        opts = {},
    },

    {
        "folke/trouble.nvim",
        cmd = {
            "Trouble",
        },
        cond = not environment.is_vscode,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>x", group = "trouble", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for trouble",
                    pattern = "IceLoad",
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
                    if view ~= nil then
                        view:wait(function()
                            require("utils").defer_fn_with_condition(function()
                                if view.win:valid() then
                                    view.win:focus()
                                end
                            end, {
                                condition = function()
                                    return vim.api.nvim_get_current_win() == view.win.win
                                end,
                            })
                        end)
                    end
                end,
                desc = "LSP Definitions (Trouble)",
                mode = "n",
            },
            {
                "gD",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_declarations" })
                    if view ~= nil then
                        view:wait(function()
                            require("utils").defer_fn_with_condition(function()
                                if view.win:valid() then
                                    view.win:focus()
                                end
                            end, {
                                condition = function()
                                    return vim.api.nvim_get_current_win() == view.win.win
                                end,
                            })
                        end)
                    end
                end,
                desc = "LSP Declarations (Trouble)",
                mode = "n",
            },
            {
                "gi",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_implementations" })
                    if view ~= nil then
                        view:wait(function()
                            require("utils").defer_fn_with_condition(function()
                                if view.win:valid() then
                                    view.win:focus()
                                end
                            end, {
                                condition = function()
                                    return vim.api.nvim_get_current_win() == view.win.win
                                end,
                            })
                        end)
                    end
                end,
                desc = "LSP Implementations (Trouble)",
                mode = "n",
            },
            {
                "gr",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_references" })
                    if view ~= nil then
                        view:wait(function()
                            require("utils").defer_fn_with_condition(function()
                                if view.win:valid() then
                                    view.win:focus()
                                end
                            end, {
                                condition = function()
                                    return vim.api.nvim_get_current_win() == view.win.win
                                end,
                            })
                        end)
                    end
                end,
                desc = "LSP References (Trouble)",
                mode = "n",
            },
            {
                "gy",
                function()
                    local view = require("trouble").toggle({ mode = "lsp_type_definitions" })
                    if view ~= nil then
                        view:wait(function()
                            require("utils").defer_fn_with_condition(function()
                                if view.win:valid() then
                                    view.win:focus()
                                end
                            end, {
                                condition = function()
                                    return vim.api.nvim_get_current_win() == view.win.win
                                end,
                            })
                        end)
                    end
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
                -- dd = "delete",
                -- d = { action = "delete", mode = "v" },
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
                --         view:filter({ buf = 0 }, { toggle = true })
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
        cond = not environment.is_vscode and environment.lint_enable,
        config = function(_, opts)
            local lint = require("utils.lint")

            local nvim_lint = require("lint")

            for linter, config in pairs(lint.lint_config) do
                if nvim_lint.linters[linter].args == nil then
                    nvim_lint.linters[linter].args = {}
                end
                local args = nvim_lint.linters[linter].args

                local prepend_args = config.prepend_args
                if prepend_args then
                    if type(prepend_args) == "function" then
                        prepend_args = prepend_args()
                    end

                    vim.list_extend(prepend_args, args)
                    args = prepend_args
                    nvim_lint.linters[linter].args = prepend_args
                    config.prepend_args = nil
                end

                local append_args = config.append_args
                if append_args then
                    if type(append_args) == "function" then
                        append_args = append_args()
                    end

                    vim.list_extend(args, append_args)
                    config.append_args = nil
                end

                nvim_lint.linters[linter] = vim.tbl_deep_extend("force", nvim_lint.linters[linter], config)
            end

            nvim_lint.linters_by_ft = lint.linters_by_ft

            -- lazyvim.plugins.linting
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
                        require("utils").defer_fn(function()
                            if vim.api.nvim_get_current_buf() == args.buf then
                                nvim_lint.try_lint(names)
                            end
                        end, {
                            timeout = 100,
                            use_timer = false,
                        })
                    end
                end,
                desc = "Lint buffer",
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
            })
        end,
        event = {
            "User LintFile",
        },
    },

    {
        "neovim/nvim-lspconfig",
        cond = not environment.is_vscode and environment.lsp_enable,
        config = function(_, opts)
            local lsp = require("utils.lsp")
            local utils = require("utils")

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            if utils.is_available("cmp-nvim-lsp") then
                capabilities = vim.tbl_deep_extend(
                    "force",
                    capabilities,
                    require("cmp_nvim_lsp").default_capabilities()
                )
            elseif utils.is_available("blink.cmp") then
                capabilities = vim.tbl_deep_extend(
                    "force",
                    capabilities,
                    require("blink.cmp").get_lsp_capabilities()
                )
            end
            vim.lsp.config("*", { capabilities = capabilities })

            for _, lsp_server in pairs(lsp.lsp_list) do
                local config = lsp.lsp_config[lsp_server]
                if config then
                    vim.lsp.config[lsp_server] = config
                end

                vim.lsp.enable(lsp_server)
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local buf = args.buf
                    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

                    local keymap = require("utils.keymap")

                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
                    end

                    if utils.is_available("which-key.nvim") then
                        require("which-key").add({
                            {
                                buffer = args.buf,
                                mode = "n",
                                { "<leader>l",  group = "lsp" },
                                { "<leader>lt", group = "lsp toggle" },
                            },
                        })
                    end

                    local function lsp_stop_client()
                        vim.schedule(function()
                            local servers_on_buffer = vim.lsp.get_clients({ bufnr = buf })
                            for _, client in ipairs(servers_on_buffer) do
                                if client.attached_buffers[buf] then
                                    client:stop()
                                end
                            end
                        end)
                    end

                    local function lsp_stop()
                        if not utils.get_setting_condition("lsp", { buf = buf }) then
                            lsp_stop_client()
                        end
                    end

                    utils.set_setting_toggle("lsp", {
                        default = true,
                        init = function()
                            lsp_stop()
                            vim.api.nvim_create_autocmd("BufReadPost", {
                                buffer = buf,
                                callback = lsp_stop,
                                desc = "Stop Lsp",
                                group = vim.api.nvim_create_augroup(string.format("LspStop%s", buf), { clear = true }),
                            })
                        end,
                        g = {
                            keymap = { buf = buf, keys = "<leader>ltl", mode = "n" },
                            opts = {
                                callback = function(enabled, prev_enabled, global_enabled)
                                    if not global_enabled then
                                        vim.lsp.stop_client(vim.lsp.get_clients())
                                    end
                                    if (not prev_enabled or not global_enabled) and enabled then
                                        utils.refresh_buf(buf)
                                    end
                                end,
                            },
                        },
                        b = {
                            keymap = { buf = buf, keys = "<leader>ltL", mode = "n" },
                            opts = {
                                callback = function(enabled, prev_enabled, global_enabled)
                                    if not enabled then
                                        lsp_stop_client()
                                    end
                                    if not prev_enabled and enabled then
                                        utils.refresh_buf(buf)
                                    end
                                end,
                            },
                        },
                    })

                    if client:supports_method("textDocument/codeAction") then
                        if utils.is_available("actions-preview.nvim") then
                            map({ "n", "x" }, keymap["<c-;>"], function() require("actions-preview").code_actions() end, "LSP code action")
                        else
                            map({ "n", "x" }, keymap["<c-;>"], function() vim.lsp.buf.code_action() end, "LSP code action")
                        end
                    end

                    if client:supports_method("textDocument/codeLens") then
                        map("n", "<leader>lc", function() vim.lsp.codelens.refresh({ bufnr = buf }) end, "LSP CodeLens refresh")
                        map("n", "<leader>lC", function() vim.lsp.codelens.run() end, "LSP CodeLens run")

                        utils.set_setting_toggle("codelens", {
                            default = true,
                            init = function()
                                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                                    buffer = buf,
                                    callback = function()
                                        if utils.get_setting_condition("codelens", { buf = buf }) then
                                            vim.lsp.codelens.refresh({ bufnr = buf })
                                        end
                                    end,
                                    desc = "Refresh codelens",
                                    group = vim.api.nvim_create_augroup(string.format("LspCodelensRefresh%s", buf), { clear = true }),
                                })
                            end,
                            g = {
                                keymap = { buf = buf, keys = "<leader>ltc", mode = "n" },
                                opts = {
                                    callback = function(enabled, prev_enabled, global_enabled)
                                        if not enabled then
                                            vim.lsp.codelens.clear(nil, buf)
                                        end
                                    end,
                                },

                            },
                            b = {
                                keymap = { buf = buf, keys = "<leader>ltC", mode = "n" },
                                opts = {
                                    callback = function(enabled, prev_enabled, global_enabled)
                                        if not enabled then
                                            vim.lsp.codelens.clear(nil, buf)
                                        end
                                    end,
                                },

                            },
                        })
                    end

                    if not utils.is_available("trouble.nvim") then
                        if client:supports_method("textDocument/definition") then
                            map("n", "gd", function() vim.lsp.buf.definition() end, "Show the definition of current symbol")
                        end
                        if client:supports_method("textDocument/declaration") then
                            map("n", "gD", function() vim.lsp.buf.declaration() end, "Declaration of current symbol")
                        end
                        if client:supports_method("textDocument/implementation") then
                            map("n", "gi", function() vim.lsp.buf.implementation() end, "Implementation of current symbol")
                        end
                        if client:supports_method("textDocument/typeDefinition") then
                            map("n", "gy", function() vim.lsp.buf.type_definition() end, "Definition of current type")
                        end
                        if client:supports_method("textDocument/references") then
                            map("n", "gr", function() vim.lsp.buf.references() end, "References of current symbol")
                        end
                    end

                    if client:supports_method("textDocument/documentHighlight") then
                        if utils.is_available("snacks.nvim") then
                            utils.set_setting_toggle("document_highlight", {
                                default = true,
                                g = {
                                    keymap = { buf = buf, keys = "<leader>lth", mode = "n" },
                                    opts = {
                                        callback = function(enabled, prev_enabled, global_enabled)
                                            if enabled then
                                                require("snacks").words.enable()
                                            else
                                                require("snacks").words.disable()
                                            end
                                        end,
                                    },

                                },
                                b = {
                                    keymap = { buf = buf, keys = "<leader>ltH", mode = "n" },
                                    opts = {
                                        callback = function(enabled, prev_enabled, global_enabled)
                                            if enabled then
                                                require("snacks").words.enable()
                                            else
                                                require("snacks").words.disable()
                                            end
                                        end,
                                    },

                                },
                            })
                        else
                            utils.set_setting_toggle("document_highlight", {
                                default = true,
                                init = function()
                                    local augroup = vim.api.nvim_create_augroup(string.format("LspDocumentHighlight%s", buf), { clear = true })
                                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                                        buffer = buf,
                                        callback = function()
                                            if utils.get_setting_condition("document_highlight", { buf = buf }) then
                                                vim.lsp.buf.document_highlight()
                                            end
                                        end,
                                        desc = "Highlight references when cursor holds",
                                        group = augroup,
                                    })
                                    vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "CursorMovedI" }, {
                                        buffer = buf,
                                        callback = function()
                                            if utils.get_setting_condition("document_highlight", { buf = buf }) then
                                                vim.lsp.buf.clear_references()
                                            end
                                        end,
                                        desc = "Clear references when cursor moves",
                                        group = augroup,
                                    })
                                end,
                                g = {
                                    keymap = { buf = buf, keys = "<leader>lth", mode = "n" },
                                    opts = {
                                        callback = function(enabled, prev_enabled, global_enabled)
                                            if not enabled then
                                                vim.lsp.buf.clear_references()
                                            end
                                        end,
                                    },

                                },
                                b = {
                                    keymap = { buf = buf, keys = "<leader>ltH", mode = "n" },
                                    opts = {
                                        callback = function(enabled, prev_enabled, global_enabled)
                                            if not enabled then
                                                vim.lsp.buf.clear_references()
                                            end
                                        end,
                                    },

                                },
                            })
                        end
                    end

                    if client:supports_method("textDocument/foldingRange") then
                        local win = vim.api.nvim_get_current_win()
                        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
                    end

                    if
                        not utils.is_available("conform.nvim")
                        and (
                            client:supports_method("textDocument/formatting")
                            or client:supports_method("textDocument/rangeFormatting")
                        )
                    then
                        local buf_format = function(opts)
                            opts = vim.tbl_deep_extend("force", {
                                timeout_ms = 5000,
                                bufnr = buf,
                                id = client.id,
                            }, opts)

                            vim.lsp.buf.format(opts)
                        end

                        map({ "n", "x" }, "<leader>f", buf_format, "Format buffer")

                        local function format(setting, opts)
                            local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buf })
                            if not is_modifiable then
                                return
                            end

                            if utils.get_setting_condition(setting, { buf = buf }) then
                                buf_format(opts)
                            end
                        end

                        local augroup = vim.api.nvim_create_augroup(string.format("LspAutoFormat%s", buf), { clear = true })
                        utils.set_setting_toggle("autoformat_on_save", {
                            default = false,
                            init = function()
                                vim.api.nvim_create_autocmd("BufWritePre", {
                                    buffer = buf,
                                    callback = function() format("autoformat_on_save") end,
                                    desc = "Autoformat on save",
                                    group = augroup,
                                })
                            end,
                            g = {
                                keymap = { buf = buf, keys = "<leader>ltfs", mode = "n" },
                            },
                            b = {
                                keymap = { buf = buf, keys = "<leader>ltfS", mode = "n" },
                            },
                        })
                        utils.set_setting_toggle("autoformat_on_quit", {
                            default = false,
                            init = function()
                                vim.api.nvim_create_autocmd("QuitPre", {
                                    buffer = buf,
                                    callback = function() format("autoformat_on_quit") end,
                                    desc = "Autoformat on quit",
                                    group = augroup,
                                })
                            end,
                            g = {
                                keymap = { buf = buf, keys = "<leader>ltfq", mode = "n" },
                            },
                            b = {
                                keymap = { buf = buf, keys = "<leader>ltfQ", mode = "n" },
                            },
                        })
                    end

                    if client:supports_method("textDocument/inlayHint") then
                        utils.set_setting_toggle("inlay_hints", {
                            default = true,
                            init = function()
                                local function toggle_inlay_hints()
                                    if vim.b[buf].inlay_hints == nil then
                                        vim.lsp.inlay_hint.enable(vim.g.inlay_hints, { bufnr = buf })
                                    else
                                        vim.lsp.inlay_hint.enable(vim.b[buf].inlay_hints, { bufnr = buf })
                                    end
                                end

                                toggle_inlay_hints()
                                vim.api.nvim_create_autocmd("BufReadPost", {
                                    buffer = buf,
                                    callback = toggle_inlay_hints,
                                    desc = "Toggle inlay hints",
                                    group = vim.api.nvim_create_augroup(string.format("LspInlayHints%s", buf), { clear = true }),
                                })
                            end,
                            g = {
                                keymap = { buf = buf, keys = "<leader>lti", mode = "n" },
                                opts = {
                                    callback = function(enabled, prev_enabled, global_enabled)
                                        if enabled ~= vim.lsp.inlay_hint.get({ bufnr = buf }) then
                                            vim.lsp.inlay_hint.enable(enabled, { bufnr = buf })
                                        end
                                    end,
                                },
                            },
                            b = {
                                keymap = { buf = buf, keys = "<leader>ltI", mode = "n" },
                                opts = {
                                    callback = function(enabled, prev_enabled, global_enabled)
                                        if enabled ~= vim.lsp.inlay_hint.get({ bufnr = buf }) then
                                            vim.lsp.inlay_hint.enable(enabled, { bufnr = buf })
                                        end
                                    end,
                                },
                            },
                        })
                    end

                    if client:supports_method("textDocument/rename") then
                        map("n", "<f2>", function() vim.lsp.buf.rename() end, "Rename current symbol")
                    end

                    if client:supports_method("textDocument/semanticTokens/full") and vim.lsp.semantic_tokens then
                        local function toggle_semantic_tokens()
                            local enabled = utils.get_setting_condition("inlay_hints", { buf = buf })
                            for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
                                if client.server_capabilities.semanticTokensProvider then
                                    vim.lsp.semantic_tokens[enabled and "start" or "stop"](buf, client.id)
                                    vim.lsp.semantic_tokens.force_refresh(buf)
                                end
                            end
                        end

                        utils.set_setting_toggle("semantic_tokens", {
                            default = true,
                            init = function()
                                toggle_semantic_tokens()
                                vim.api.nvim_create_autocmd("BufReadPost", {
                                    buffer = buf,
                                    callback = toggle_semantic_tokens,
                                    desc = "Toggle semantic tokens",
                                    group = vim.api.nvim_create_augroup(string.format("LspSemanticTokens%s", buf), { clear = true }),
                                })
                            end,
                            g = {
                                keymap = { buf = buf, keys = "<leader>lts", mode = "n" },
                                opts = {
                                    callback = function(enabled, prev_enabled, global_enabled)
                                        if enabled ~= prev_enabled then
                                            toggle_semantic_tokens()
                                        end
                                    end,
                                },
                            },
                            b = {
                                keymap = { buf = buf, keys = "<leader>ltS", mode = "n" },
                                opts = {
                                    callback = function(enabled, prev_enabled, global_enabled)
                                        if enabled ~= prev_enabled then
                                            toggle_semantic_tokens()
                                        end
                                    end,
                                },
                            },
                        })
                    end

                    if client:supports_method("textDocument/signatureHelp") then
                        map("n", "gK", function() vim.lsp.buf.signature_help() end, "Signature help")
                        map({ "i", "s" }, "<c-k>", function() vim.lsp.buf.signature_help() end, "Signature help")
                    end

                    if not utils.is_available("snacks.nvim") then
                        if client:supports_method("workspace/symbol") then
                            map("n", "<leader>ls", function() vim.lsp.buf.document_symbol() end, "Search symbols")
                            map("n", "<leader>lS", function() vim.lsp.buf.workspace_symbol() end, "Search workspace symbols")
                        end
                    end

                    map("n", "<leader>li", function() vim.api.nvim_command("LspInfo") end, "LSP information")

                    map("n", "gl", function() vim.diagnostic.open_float() end, "Hover diagnostics")
                    if not utils.is_available("trouble.nvim") then
                        map("n", "<s-f8>", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
                        map("n", "<f8>", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
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
                    -- Autocmd configuration.
                    -- If enabled, automatically defines an autocmd to show the lightbulb.
                    -- If disabled, you will have to manually call |NvimLightbulb.update_lightbulb|.
                    -- Only works if configured during NvimLightbulb.setup
                    autocmd = {
                        -- Whether or not to enable autocmd creation.
                        enabled = true,
                    },
                },
            },
        },
        event = {
            "User LspFile",
        },
        init = function()
            local utils = require("utils")
            utils.create_once_autocmd("User", {
                callback = function()
                    local icons = require("utils.icons")

                    local virtual_text
                    if utils.is_available("tiny-inline-diagnostic.nvim") then
                        virtual_text = false
                    else
                        virtual_text = {
                            source = "if_many",
                            spacing = 4,
                            prefix = icons.dap.Breakpoint,
                        }
                    end

                    -- Customizing how diagnostics are displayed
                    vim.diagnostic.config({
                        virtual_text = virtual_text,
                        signs = {
                            text = {
                                [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
                                [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
                                [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
                                [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
                            },
                        },
                        float = {
                            border = "rounded",
                        },
                        update_in_insert = true,
                        severity_sort = true,
                    })
                end,
                desc = "Lspconfig init",
                pattern = "IceLoad",
            })
        end,
    },

    {
        "rachartier/tiny-inline-diagnostic.nvim",
        cond = not environment.is_vscode and environment.lsp_enable,
        event = {
            "LspAttach",
        },
        opts = {
            preset = "nonerdfont", -- Can be: "modern", "classic", "minimal", "powerline", ghost", "simple", "nonerdfont", "amongus"
            options = {
                -- Enable diagnostic message on all lines.
                multilines = true,

                -- Enable diagnostics on Insert mode. You should also se the `throttle` option to 0, as some artefacts may appear.
                enable_on_insert = true,
            },
        },
    },
}
