local variables = {}

function variables:load_variables()
    -- running environment

    local sysname = vim.loop.os_uname().sysname:lower()
    local release = vim.loop.os_uname().release:lower()

    self.is_windows = sysname == "windows_nt"
    self.is_mac = sysname == "darwin"
    self.is_linux = sysname == "linux"
    self.is_wsl = self.is_linux and release:find("wsl") and true or false
    self.is_vscode = vim.g.vscode



    -- keymap

    self.keymap = {
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



    -- icons

    self.icons = {
        dap = {
            Breakpoint = " ",
            BreakpointCondition = " ",
            BreakpointRejected = { " ", "DiagnosticError" },
            LogPoint = ".>",
            Stopped = { " ", "DiagnosticWarn", "DapStoppedLine" },
        },
        diagnostics = {
            Error = " ",
            Hint = " ",
            Info = " ",
            Warn = " ",
        },
        git = {
            added = " ",
            modified = " ",
            removed = " ",
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



    -- path

    self.config_path = vim.fn.stdpath("config")
    if self.is_windows then
        self.config_path = string.gsub(self.config_path, "\\", "/")
    end
    self.data_path = vim.fn.stdpath("data")
    if self.is_windows then
        self.data_path = string.gsub(self.data_path, "\\", "/")
    end
    self.home_path = vim.env.HOME
    if self.is_windows then
        self.home_path = string.gsub(self.home_path, "\\", "/")
    end

    self.mason_install_root_path = self.data_path .. "/lazy/mason.nvim/mason"

    self.vscode_path = nil
    if self.is_windows then
        self.vscode_path = string.gsub(vim.env.APPDATA, "\\", "/") .. "/Code"
    elseif self.is_mac then
        self.vscode_path = vim.env.HOME .. "/Library/Application\\ Support/Code"
    elseif self.is_linux then
        self.vscode_path = vim.env.HOME .. "/.config/Code"
    end
    self.vscode_snippet_path = self.vscode_path .. "/User/snippets"
    self.vscode_extension_path = self.home_path .. "/.vscode/extensions"



    -- list

    -- skip when <c-2>
    self.skip_filetype_list1 = {
        "dap",
        "DiffviewFiles",
        "DiffviewFileHistory",
        "notify",
        "nvim-docs-view",
        "NvimTree",
        "toggleterm",
        "Trouble",
    }
    -- skip when <c-j>, <c-k>
    self.skip_filetype_list2 = {
        "DiffviewFiles",
        "DiffviewFileHistory",
        "nvim-docs-view",
        "NvimTree",
        "toggleterm",
        "Trouble",
    }
    self.is_start_with_skip_filetype = function(filetype, skip_filetye_list)
        for _, skip_filetype in ipairs(skip_filetye_list) do
            if filetype:find(skip_filetype, 1, true) == 1 then
                return true
            end
        end
        return false
    end
    self.skip_filetype = function(skip_filetype_list, param)
        local filetype = vim.bo.filetype
        local max_skip = 20
        while self.is_start_with_skip_filetype(filetype, skip_filetype_list) and max_skip > 0 do
            vim.cmd.wincmd(param)
            filetype = vim.bo.filetype
            max_skip = max_skip - 1
        end
    end

    -- toggle left panel
    self.toggle_filetype_list1 = {
        "DiffviewFiles",
        "DiffviewFileHistory",
        "NvimTree",
    }
    -- toggle bottom panel
    self.toggle_filetype_list2 = {
        "toggleterm",
        "Trouble",
    }
    -- toggle right panel
    self.toggle_filetype_list3 = {
        "nvim-docs-view",
    }
    self.is_start_with_toggle_filetype = function(filetype, toggle_filetype_list)
        for _, toggle_filetype in ipairs(toggle_filetype_list) do
            if filetype:find(toggle_filetype, 1, true) == 1 then
                return true
            end
        end
        return false
    end
    self.toggle_filetype = function(toggle_filetype_list)
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
        if self.is_start_with_toggle_filetype(filetype, toggle_filetype_list) then
            if filetype == "NvimTree" then
                require("nvim-tree.api").tree.close()
            else
                vim.api.nvim_win_close(win, false)
            end
            return true
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            buf = vim.api.nvim_win_get_buf(win)
            filetype = vim.api.nvim_buf_get_option(buf, "filetype")
            if self.is_start_with_toggle_filetype(filetype, toggle_filetype_list) then
                vim.api.nvim_set_current_win(win)
                return true
            end
        end

        return false
    end



    -- tex like filetype

    self.tex_filetype = {
        "markdown",
        "plaintex",
        "tex",
        "text",
    }



    -- lsp

    self.lsp = function(lspconfig, default_config)
        return {
            bashls = function()
                lspconfig.bashls.setup(default_config)
            end,
            lua_ls = function()
                lspconfig.lua_ls.setup(vim.tbl_deep_extend("keep", {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                            workspace = {
                                checkThirdParty = false,
                            },
                        },
                    },
                }, default_config))
            end,
            marksman = function()
                lspconfig.marksman.setup(default_config)
            end,
            pyright = function()
                lspconfig.pyright.setup(default_config)
            end,
            rust_analyzer = function()
                -- 由 rust-tools 设置
                -- lspconfig.rust_analyzer.setup(default_config)
            end,
        }
    end

    self.lsp_list = {}
    for lsp, _ in pairs(self.lsp(nil, nil)) do
        self.lsp_list[#self.lsp_list + 1] = lsp
    end



    -- dap

    self.dap = function()
        return {
            -- 由 rust-tools 设置
            codelldb = function(config)
                -- config.adapters = {
                --     type = "server",
                --     port = "${port}",
                --     executable = {
                --         -- CHANGE THIS to your path!
                --         command = self.mason_install_root_path .. "/packages/codelldb/extension/adapter/codelldb",
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

                -- require("mason-nvim-dap").default_setup(config)
            end,
            python = function(config)
                config.adapters = {
                    type = "executable",
                    command = self.home_path .. "/miniconda3/python",
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
                            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
                            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
                            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
                            local cwd = vim.fn.getcwd()
                            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                                return cwd .. "/venv/bin/python"
                            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                                return cwd .. "/.venv/bin/python"
                            else
                                return self.home_path .. "/miniconda3/python"
                            end
                        end,
                    },
                }

                require("mason-nvim-dap").default_setup(config)
            end,
        }
    end

    self.dap_list = {}
    for dap, _ in pairs(self.dap()) do
        self.dap_list[#self.dap_list + 1] = dap
    end



    -- null-ls

    self.null_ls_builtins = function(null_ls)
        return {
            black = function(source_name, methods)
                null_ls.register(null_ls.builtins.formatting.black)
            end,
            gitsigns = function(source_name, methods)
                null_ls.register(null_ls.builtins.code_actions.gitsigns)
            end,
            rustfmt = function(source_name, methods)
                null_ls.register(null_ls.builtins.formatting.rustfmt)
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
            stylua = function(source_name, methods)
                local line_endings = "Unix"
                if variables.is_windows then
                    line_endings = "Windows"
                end
                null_ls.register(null_ls.builtins.formatting.stylua.with({
                    extra_args = {
                        "--line-endings", line_endings,
                        "--indent-type", "Spaces",
                        "--quote-style", "ForceDouble",
                    },
                }))
            end,
        }
    end

    self.null_ls_builtins_list = {}
    for null_ls_builtin, _ in pairs(self.null_ls_builtins(nil)) do
        self.null_ls_builtins_list[#self.null_ls_builtins_list + 1] = null_ls_builtin
    end
end

variables:load_variables()

return variables