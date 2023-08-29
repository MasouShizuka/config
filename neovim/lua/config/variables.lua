local M = {}

function M.load_running_environment()
    M.is_windows = vim.fn.has("win32") == 1
    M.is_mac = vim.fn.has("mac") == 1
    M.is_linux = vim.fn.has("linux") == 1
    M.is_wsl = vim.fn.has("wsl") == 1
    M.is_vscode = vim.g.vscode
end

function M.load_path()
    M.config_path = vim.fn.stdpath("config")
    if M.is_windows then
        M.config_path = M.config_path:gsub("\\", "/")
    end

    M.data_path = vim.fn.stdpath("data")
    if M.is_windows then
        M.data_path = M.data_path:gsub("\\", "/")
    end
    M.wsl_data_path = "/mnt/c/Users/MasouShizuka/AppData/Local/nvim-data"

    M.home_path = vim.env.HOME
    if M.is_windows then
        M.home_path = M.home_path:gsub("\\", "/")
    end

    M.conda_path = M.home_path .. "/miniconda3"
    M.python_path = M.conda_path .. "/bin/python"
    if M.is_windows then
        M.python_path = M.conda_path .. "/python.exe"
    end
    M.get_python_envs_path = function()
        local function exists(path)
            local ok, err, code = os.rename(path, path)
            if not ok then
                if code == 13 then
                    -- Permission denied, but it exists
                    return true
                end
            end
            return ok
        end

        local python_envs_path = nil

        local conda_envs_path = M.conda_path .. "/envs"
        local envs = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local envs_path = conda_envs_path .. "/" .. envs
        if exists(envs_path) then
            python_envs_path = envs_path .. "/bin/python"
            if M.is_windows then
                python_envs_path = envs_path .. "/python.exe"
            end
        end

        return python_envs_path
    end

    M.mason_install_root_path = M.data_path .. "/lazy/mason.nvim/mason"

    M.vscode_path = nil
    if M.is_windows then
        M.vscode_path = vim.env.APPDATA:gsub("\\", "/") .. "/Code"
    elseif M.is_mac then
        M.vscode_path = vim.env.HOME .. "/Library/Application\\ Support/Code"
    elseif M.is_linux then
        M.vscode_path = vim.env.HOME .. "/.config/Code"
    end
    M.vscode_snippet_path = M.vscode_path .. "/User/snippets"
    M.vscode_extension_path = M.home_path .. "/.vscode/extensions"
end

function M.load_icons()
    M.icons = {
        dap = {
            Breakpoint = " ",
            BreakpointCondition = " ",
            BreakpointRejected = { " ", "DiagnosticError" },
            LogPoint = ".>",
            Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        },
        diagnostics = {
            error = " ",
            hint = " ",
            info = " ",
            warn = " ",
        },
        git = {
            added     = " ",
            conflict  = " ",
            deleted   = " ",
            ignored   = "◌ ",
            modified  = " ",
            renamed   = "➜ ",
            staged    = " ",
            unstaged  = "✓ ",
            untracked = "★ ",
        },
        kinds = {
            Array = " ",
            Boolean = " ",
            Class = " ",
            Color = " ",
            Constant = " ",
            Constructor = " ",
            Copilot = " ",
            Enum = " ",
            EnumMember = " ",
            Event = " ",
            Field = " ",
            File = " ",
            Folder = " ",
            Function = " ",
            Interface = " ",
            Key = " ",
            Keyword = " ",
            Method = " ",
            Module = " ",
            Namespace = " ",
            Null = " ",
            Number = " ",
            Object = " ",
            Operator = " ",
            Package = " ",
            Property = " ",
            Reference = " ",
            Snippet = " ",
            String = " ",
            Struct = " ",
            Text = " ",
            TypeParameter = " ",
            Unit = " ",
            Value = " ",
            Variable = " ",
        },
    }
end

function M.load_keymap()
    if not M.is_wsl then
        M.keymap = {
            ["<c-1>"] = "<c-f1>",
            ["<c-2>"] = "<c-f2>",
            ["<c-3>"] = "<c-f3>",
            ["<c-4>"] = "<c-f4>",
            ["<c-space>"] = "<c-f5>",
            ["<c-,>"] = "<c-f6>",
            ["<c-.>"] = "<c-f7>",
            ["<c-;>"] = "<c-f8>",
            ["<c-s-n>"] = "<c-f9>",
            ["<c-s-t>"] = "<c-f10>",
        }
    else
        M.keymap = {
            ["<c-1>"] = "<f25>",
            ["<c-2>"] = "<f26>",
            ["<c-3>"] = "<f27>",
            ["<c-4>"] = "<f28>",
            ["<c-space>"] = "<f29>",
            ["<c-,>"] = "<f30>",
            ["<c-.>"] = "<f31>",
            ["<c-;>"] = "<f32>",
            ["<c-s-n>"] = "<f33>",
            ["<c-s-t>"] = "<f34>",
        }
    end
end

function M.load_filtyppe_list()
    -- skip when <c-2>
    M.skip_filetype_list1 = {
        "aerial",
        "dap",
        "DiffviewFiles",
        "DiffviewFileHistory",
        "help",
        "notify",
        "neo-tree",
        "nvim-docs-view",
        "NvimTree",
        "toggleterm",
        "Trouble",
    }
    -- skip when <c-j>, <c-k>
    M.skip_filetype_list2 = {
        "aerial",
        "dap",
        "DiffviewFiles",
        "DiffviewFileHistory",
        "help",
        "neo-tree",
        "nvim-docs-view",
        "NvimTree",
        "toggleterm",
        "Trouble",
    }
    -- plugins skip these
    M.skip_filetype_list3 = {
        "aerial",
        "DiffviewFiles",
        "DiffviewFileHistory",
        "neo-tree",
        "NvimTree",
        "toggleterm",
        "Trouble",
    }
    M.is_start_with_skip_filetype = function(filetype, skip_filetye_list)
        for _, skip_filetype in ipairs(skip_filetye_list) do
            if filetype:find(skip_filetype, 1, true) == 1 then
                return true
            end
        end
        return false
    end
    M.skip_filetype = function(skip_filetype_list, param)
        local filetype = vim.bo.filetype
        local max_skip = 20
        while M.is_start_with_skip_filetype(filetype, skip_filetype_list) and max_skip > 0 do
            vim.cmd.wincmd(param)
            filetype = vim.bo.filetype
            max_skip = max_skip - 1
        end
    end

    -- toggle left panel
    M.toggle_filetype_list1 = {
        ["aerial"] = function() vim.api.nvim_command("AerialClose") end,
        ["dapui_scopes"] = false,
        ["dapui_breakpoints"] = false,
        ["dapui_stacks"] = false,
        ["dapui_watches"] = false,
        ["DiffviewFiles"] = function() vim.api.nvim_command("DiffviewClose") end,
        ["DiffviewFileHistory"] = function() vim.api.nvim_command("DiffviewClose") end,
        ["neo-tree"] = function() require("neo-tree.command").execute({ action = "close" }) end,
        ["NvimTree"] = function() require("nvim-tree.api").tree.close() end,
    }
    -- toggle bottom panel
    M.toggle_filetype_list2 = {
        ["dap-repl"] = false,
        ["dapui_console"] = false,
        ["toggleterm"] = function() vim.api.nvim_command("ToggleTerm") end,
        ["Trouble"] = function() vim.api.nvim_command("TroubleClose") end,
    }
    -- toggle right panel
    M.toggle_filetype_list3 = {
        ["help"] = false,
        ["nvim-docs-view"] = function() vim.api.nvim_command("DocsViewToggle") end,
    }
    M.is_start_with_toggle_filetype = function(filetype, toggle_filetype_list)
        for toggle_filetype, close_function in pairs(toggle_filetype_list) do
            if filetype:find(toggle_filetype, 1, true) == 1 then
                return true, close_function
            end
        end
        return false, nil
    end
    M.is_toggle_filetype_focused = function(toggle_filetype_list, close)
        local ok, close_function = M.is_start_with_toggle_filetype(vim.bo.filetype, toggle_filetype_list)
        if ok then
            if type(close_function) ~= "function" then
                close_function = function()
                    vim.api.nvim_win_close(vim.api.nvim_get_current_win(), false)
                end
            end

            if close then
                close_function()
            end

            return true, close_function
        end

        return false, nil
    end
    M.is_toggle_filetype_opened = function(toggle_filetype_list, focus)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })

            local ok, _ = M.is_start_with_toggle_filetype(filetype, toggle_filetype_list)
            if ok then
                if focus then
                    vim.api.nvim_set_current_win(win)
                end

                return true, win
            end
        end

        return false, nil
    end
    M.toggle_filetype = function(toggle_filetype_list)
        local is_focused, _ = M.is_toggle_filetype_focused(toggle_filetype_list, true)
        if is_focused then
            return true
        end

        local is_opened, _ = M.is_toggle_filetype_opened(toggle_filetype_list, true)
        if is_opened then
            return true
        end

        return false
    end
end

function M.load_language_filetype()
    -- tex like filetype
    M.tex_filetype = {
        "markdown",
        "plaintex",
        "tex",
        "text",
    }
end

function M.load_lsp()
    M.lsp = function(lspconfig, default_config)
        return {
            bashls = function()
                -- https://github.com/williamboman/mason.nvim/issues/1315
                -- wsl 下安装后 mason.nvim/mason/bin/bash-language-server 中的路径错误
                -- 需要将 "$basedir/../bash-language-server/out/cli.js" 改为 "$basedir/../packages/bash-language-server/node_modules/bash-language-server/out/cli.js"
                lspconfig.bashls.setup(default_config)
            end,
            -- jedi_language_server = function()
            --     local python_envs_path = M.get_python_envs_path()
            --     if python_envs_path then
            --         vim.notify(("Activated:\n%s"):format(python_envs_path), vim.log.levels.INFO, { title = "jedi-language-server" })
            --     else
            --         python_envs_path = M.python_path
            --     end
            --
            --     lspconfig.jedi_language_server.setup(vim.tbl_deep_extend("keep", {
            --         root_dir = lspconfig.util.root_pattern("*"),
            --         init_options = {
            --             diagnostics = {
            --                 enable = true,
            --             },
            --             workspace = {
            --                 environmentPath = python_envs_path,
            --             },
            --         },
            --     }, default_config))
            -- end,
            jsonls = function()
                lspconfig.jsonls.setup(default_config)
            end,
            lua_ls = function()
                lspconfig.lua_ls.setup(vim.tbl_deep_extend("keep", {
                    settings = {
                        Lua = {
                            runtime = {
                                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                                version = "LuaJIT",
                            },
                            diagnostics = {
                                -- Get the language server to recognize the `vim` global
                                globals = {
                                    "mp",
                                    "vim",
                                },
                            },
                            workspace = {
                                -- Make the server aware of Neovim runtime files
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            format = {
                                enable = true,
                                defaultConfig = {
                                    quote_style = "double",
                                    max_line_length = "10000",
                                    trailing_table_separator = "smart",
                                },
                            },
                            telemetry = {
                                enable = false,
                            },
                        },
                    },
                }, default_config))
            end,
            marksman = function()
                lspconfig.marksman.setup(default_config)
            end,
            pyright = function()
                local python_envs_path = M.get_python_envs_path()
                if python_envs_path then
                    vim.notify(("Activated:\n%s"):format(python_envs_path), vim.log.levels.INFO, { title = "pyright" })
                else
                    python_envs_path = M.python_path
                end

                lspconfig.pyright.setup(vim.tbl_deep_extend("keep", {
                    root_dir = lspconfig.util.root_pattern("*"),
                    settings = {
                        python = {
                            analysis = {
                                diagnosticMode = "openFilesOnly",
                            },
                            pythonPath = python_envs_path,
                        },
                    },
                }, default_config))
            end,
            -- 由 rust-tools 设置
            -- rust_analyzer = function()
            --     lspconfig.rust_analyzer.setup(default_config)
            -- end,
        }
    end

    M.lsp_list = {}
    for lsp, _ in pairs(M.lsp(nil, nil)) do
        M.lsp_list[#M.lsp_list + 1] = lsp
    end

    M.format = function()
        -- Gets all lsp clients that support formatting
        -- and have not disabled it in their client config
        ---@param client lsp.Client
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

        -- Gets all lsp clients that support formatting.
        -- When a null-ls formatter is available for the current filetype,
        -- only null-ls formatters are returned.
        local function get_formatters(bufnr)
            local ft = vim.bo[bufnr].filetype
            -- check if we have any null-ls formatters for the current filetype
            local null_ls = package.loaded["null-ls"] and require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") or {}

            ---@class LazyVimFormatters
            local ret = {
                ---@type lsp.Client[]
                active = {},
                ---@type lsp.Client[]
                available = {},
                null_ls = null_ls,
            }

            ---@type lsp.Client[]
            local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
            for _, client in ipairs(clients) do
                if supports_format(client) then
                    if (#null_ls > 0 and client.name == "null-ls") or #null_ls == 0 then
                        table.insert(ret.active, client)
                    else
                        table.insert(ret.available, client)
                    end
                end
            end

            return ret
        end

        local buf = vim.api.nvim_get_current_buf()

        local formatters = get_formatters(buf)
        local client_ids = vim.tbl_map(function(client)
            return client.id
        end, formatters.active)

        if #client_ids == 0 then
            return
        end

        vim.lsp.buf.format({
            async = true,
            bufnr = buf,
            filter = function(client)
                return vim.tbl_contains(client_ids, client.id)
            end,
        })
    end
end

function M.load_dap()
    M.dap = function(mason_nvim_dap)
        return {
            -- 由 rust-tools 设置
            codelldb = function(config)
                -- config.adapters = {
                --     type = "server",
                --     port = "${port}",
                --     executable = {
                --         -- CHANGE THIS to your path!
                --         command = M.mason_install_root_path .. "/packages/codelldb/extension/adapter/codelldb",
                --         args = { "--port", "${port}" },
                --         -- On windows you may have to uncomment this:
                --         detached = false,
                --     },
                -- }

                -- config.configurations = {
                --     {
                --         name = "Launch file",
                --         type = "codelldb",
                --         request = "launch",
                --         program = function()
                --             return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                --         end,
                --         cwd = "${workspaceFolder}",
                --         stopOnEntry = false,
                --     },
                -- }

                -- mason_nvim_dap.default_setup(config)
            end,
            python = function(config)
                config.adapters = {
                    type = "executable",
                    command = M.python_path,
                    args = { "-m", "debugpy.adapter" },
                    options = {
                        source_filetype = "python",
                    },
                }

                config.configurations = {
                    {
                        -- The first three options are required by nvim-dap
                        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                        request = "launch",
                        name = "Launch file",
                        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

                        program = "${file}", -- This configuration will launch the current file if used.
                        pythonPath = function()
                            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itM.
                            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                            local cwd = vim.fn.getcwd()
                            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                                return cwd .. "/venv/bin/python"
                            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                                return cwd .. "/.venv/bin/python"
                            else
                                return M.python_path
                            end
                        end,
                    },
                }

                mason_nvim_dap.default_setup(config)
            end,
        }
    end

    M.dap_list = {}
    for dap, _ in pairs(M.dap()) do
        M.dap_list[#M.dap_list + 1] = dap
    end
end

function M.load_null_ls()
    M.null_ls_builtins = function(null_ls)
        return {
            black = function(source_name, methods)
                null_ls.register(null_ls.builtins.formatting.black)
            end,
            gitsigns = function(source_name, methods)
                null_ls.register(null_ls.builtins.code_actions.gitsigns)
            end,
            isort = function(source_name, methods)
                null_ls.register(null_ls.builtins.formatting.isort.with({
                    extra_args = {
                        "--multi-line", "3",
                        "--trailing-comma",
                        "--profile", "black",
                    },
                }))
            end,
            shellcheck = function(source_name, methods)
                null_ls.register(null_ls.builtins.code_actions.shellcheck)
                null_ls.register(null_ls.builtins.diagnostics.shellcheck)
            end,
            shfmt = function(source_name, methods)
                null_ls.register(null_ls.builtins.formatting.shfmt.with({
                    extra_args = {
                        "-i", 4,
                    },
                }))
            end,
        }
    end

    M.null_ls_builtins_list = {}
    for null_ls_builtin, _ in pairs(M.null_ls_builtins(nil)) do
        M.null_ls_builtins_list[#M.null_ls_builtins_list + 1] = null_ls_builtin
    end
end

M.load_running_environment()
M.load_path()

M.load_icons()
M.load_keymap()

M.load_filtyppe_list()
M.load_language_filetype()

M.load_lsp()
M.load_dap()
M.load_null_ls()

return M
