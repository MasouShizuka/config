local environment = require("utils.environment")
local icons = require("utils.icons")
local keymap = require("utils.keymap")
local lsp = require("utils.lsp")
local null_ls = require("utils.null_ls")
local path = require("utils.path")
local utils = require("utils")

return {
    -- NOTE: glance 通过 uri 比较来确定当前位置，但没有考虑到相同 uri 可能存在差异，导致定位失败
    -- 比如转义：: <-> %3A
    -- 比如路径的 uri 的大小写可能不同：d:/path <-> D:/path
    -- 因此需要对 lua/glance/list.lua 的 is_starting_location 函数进行修改，将：
    -- ╭──────────────────────────────────────────────────────────╮
    -- │ if location_uri ~= position_params.textDocument.uri then │
    -- │   return false                                           │
    -- │ end                                                      │
    -- ╰──────────────────────────────────────────────────────────╯
    -- 修改为：
    -- ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    -- │ if vim.uri_to_fname(location_uri:lower()) ~= vim.uri_to_fname(position_params.textDocument.uri:lower()) then │
    -- │   return false                                                                                               │
    -- │ end                                                                                                          │
    -- ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    --
    -- NOTE: glance 在进行相同的行为时可能会产生不同的顺序，需要在渲染前进行排序
    -- 因此需要对 lua/glance/list.lua 的 List:render 函数进行修改，将：
    -- ╭─────────────────────────────────────────╮
    -- │ for filename, group in pairs(groups) do │
    -- ╰─────────────────────────────────────────╯
    -- 修改为：
    -- ╭────────────────────────────────────╮
    -- │ local keys = vim.tbl_keys(groups)  │
    -- │ table.sort(keys)                   │
    -- │ for _, filename in ipairs(keys) do │
    -- │   local group = groups[filename]   │
    -- ╰────────────────────────────────────╯
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

                            vim.cmd.normal({ "zt", bang = true })
                        else
                            open(results)
                        end
                    end,
                    after_close = function()
                        vim.cmd.normal({ "zt", bang = true })
                    end,
                },
                folds = {
                    folded = false, -- Automatically fold list on startup
                },
            }
        end,
    },

    -- NOTE: trouble 无法在打开时 focus 与当前 cursor 最近的 item
    -- 若想实现以上功能，需要对 lua/trouble/view.lua 的 View:setup 函数的末尾添加：
    -- ╭────────────────────────────────────────────────────────────────────╮
    -- │ local parent_bufnr = vim.api.nvim_win_get_buf(self.parent)         │
    -- │ local parent_row = vim.api.nvim_win_get_cursor(self.parent)[1]     │
    -- │ -- 其他 plugin 调用 trouble 可能会导致 self.items 不能及时更新     │
    -- │ -- 因此使用 defer_fn 延迟对 self.items 的访问                      │
    -- │ vim.defer_fn(function ()                                           │
    -- │   local row = nil                                                  │
    -- │                                                                    │
    -- │   local min_distance = math.huge                                   │
    -- │   for i = 1, vim.api.nvim_buf_line_count(self.buf), 1 do           │
    -- │     local item = self.items[i]                                     │
    -- │     if item == nil or (opts.skip_groups and item.is_file) then     │
    -- │       goto continue                                                │
    -- │     end                                                            │
    -- │     if item.bufnr ~= parent_bufnr then                             │
    -- │       goto continue                                                │
    -- │     end                                                            │
    -- │                                                                    │
    -- │     local distance = math.abs(item.lnum - parent_row)              │
    -- │     if distance < min_distance then                                │
    -- │       row = i                                                      │
    -- │       min_distance = distance                                      │
    -- │     end                                                            │
    -- │                                                                    │
    -- │     ::continue::                                                   │
    -- │   end                                                              │
    -- │                                                                    │
    -- │   if row then                                                      │
    -- │     vim.api.nvim_win_set_cursor(self.win, { row, self:get_col() }) │
    -- │   end                                                              │
    -- │ end, 200)                                                          │
    -- ╰────────────────────────────────────────────────────────────────────╯
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
                        vim.keymap.set({ "n", "x" }, keymap["<c-;>"], function() vim.lsp.buf.code_action() end, { buffer = buf, desc = "LSP code action", silent = true })
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

                    if client.supports_method("textDocument/formatting") or client.supports_method("textDocument/rangeFormatting") then
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
                        local function get_formatters()
                            local formatters = {}

                            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                            -- check if we have any null-ls formatters for the current filetype
                            local null_ls_formatters = package.loaded["null-ls"] and require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") or {}

                            local clients = vim.lsp.get_clients({ bufnr = buf })
                            if #null_ls_formatters > 0 then
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
                            local formatters = get_formatters()
                            local client_ids = vim.tbl_map(function(client)
                                return client.id
                            end, formatters)

                            if #client_ids == 0 then
                                return
                            end

                            vim.lsp.buf.format({
                                timeout_ms = 5000,
                                bufnr = buf,
                                filter = function(client)
                                    return vim.tbl_contains(client_ids, client.id)
                                end,
                            })
                        end

                        vim.keymap.set({ "n", "x" }, "<leader>f", format, { buffer = buf, desc = "Format buffer", silent = true })

                        if vim.g.autoformat_enabled == nil then
                            vim.g.autoformat_enabled = false
                        end

                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = buf,
                            callback = function()
                                if vim.b[buf].autoformat_enabled == nil and vim.g.autoformat_enabled or vim.b[buf].autoformat_enabled then
                                    format()
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
                    if utils.is_available("none-ls.nvim") then
                        vim.keymap.set("n", "<leader>lI", function() vim.api.nvim_command("NullLsInfo") end, { buffer = buf, desc = "Null-ls information", silent = true })
                    end

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
    --             -- ["<2-leftmouse>"] = "actions.jump",
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
