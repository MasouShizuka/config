local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

local M = {}

M.lsp = function(lspconfig, default_config)
    return {
        bashls = function()
            -- https://github.com/williamboman/mason.nvim/issues/1315
            -- wsl 下安装后 mason.nvim/mason/bin/bash-language-server 中的路径错误
            -- 需要将 "$basedir/../bash-language-server/out/cli.js" 改为 "$basedir/../packages/bash-language-server/node_modules/bash-language-server/out/cli.js"
            lspconfig.bashls.setup(vim.tbl_deep_extend("keep", {}, default_config))
        end,
        -- jedi 速度明显快于 pyright
        -- jedi_language_server = function()
        --     local python_path = path.python_path
        --     if not utils.is_available("venv-selector.nvim") then
        --         local python_envs_path = path.get_python_envs_path()
        --         if python_envs_path then
        --             python_path = python_envs_path
        --             vim.notify(("Activated:\n%s"):format(python_envs_path), vim.log.levels.INFO, { title = "jedi-language-server" })
        --         end
        --     end
        --
        --     lspconfig.jedi_language_server.setup(vim.tbl_deep_extend("keep", {
        --         root_dir = lspconfig.util.root_pattern("*"),
        --         init_options = {
        --             diagnostics = {
        --                 enable = true,
        --             },
        --             workspace = {
        --                 environmentPath = python_path,
        --             },
        --         },
        --     }, default_config))
        -- end,
        jsonls = function()
            lspconfig.jsonls.setup(vim.tbl_deep_extend("keep", {}, default_config))
        end,
        lua_ls = function()
            local library = {
                vim.env.VIMRUNTIME,
            }

            local cwd = vim.fn.getcwd()
            if environment.is_windows then
                cwd = cwd:gsub("\\", "/")
            end
            if cwd:match(path.config_path) then
                if utils.is_available("neodev.nvim") then
                    require("neodev")
                end
                table.insert(library, path.config_path .. "/lua")
            end

            lspconfig.lua_ls.setup(vim.tbl_deep_extend("keep", {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        diagnostics = {
                            globals = {
                                "mp",
                                "vim",
                            },
                        },
                        format = {
                            defaultConfig = {
                                quote_style = "double",
                                max_line_length = "10000",
                                trailing_table_separator = "smart",
                            },
                            enable = true,
                        },
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim)
                            version = "LuaJIT",
                        },
                        -- Make the server aware of Neovim runtime files
                        workspace = {
                            checkThirdParty = "Disable",
                            library = library,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }, default_config))
        end,
        marksman = function()
            lspconfig.marksman.setup(vim.tbl_deep_extend("keep", {}, default_config))
        end,
        pyright = function()
            local python_path = path.python_path
            if not utils.is_available("venv-selector.nvim") then
                local python_envs_path = path.get_python_envs_path()
                if python_envs_path then
                    python_path = python_envs_path
                    vim.notify(("Activated:\n%s"):format(python_envs_path), vim.log.levels.INFO, { title = "pyright" })
                end
            end

            lspconfig.pyright.setup(vim.tbl_deep_extend("keep", {
                root_dir = lspconfig.util.root_pattern("*"),
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true,
                        },
                        pythonPath = python_path,
                    },
                },
            }, default_config))
        end,
        -- 由 rust-tools 设置
        -- rust_analyzer = function()
        --     lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("keep", {}, default_config))
        -- end,
        texlab = function()
            local executable = "sioyek"
            local args = {
                "--nofocus",
                "--reuse-window",
                "--forward-search-file",
                "%f",
                "--forward-search-line",
                "%l",
                "%p",
            }

            lspconfig.texlab.setup(vim.tbl_deep_extend("keep", {
                root_dir = lspconfig.util.root_pattern("*"),
                settings = {
                    texlab = {
                        build = {
                            forwardSearchAfter = true,
                        },
                        forwardSearch = {
                            executable = executable,
                            args = args,
                        },
                        inlayHints = {
                            labelDefinitions = true,
                            labelReferences = false,
                        },
                    },
                },
            }, default_config))

            vim.api.nvim_create_user_command("TexlabCleanAuxiliary", function()
                vim.lsp.buf.execute_command({ command = "texlab.cleanAuxiliary", arguments = { { uri = vim.uri_from_bufnr(0) } } })
            end, { desc = "Clean Auxiliary" })
            vim.api.nvim_create_user_command("TexlabCleanArtifacts", function()
                vim.lsp.buf.execute_command({ command = "texlab.cleanArtifacts", arguments = { { uri = vim.uri_from_bufnr(0) } } })
            end, { desc = "Clean Artifacts" })
            vim.api.nvim_create_user_command("TexlabCancelBuild", function()
                vim.lsp.buf.execute_command({ command = "texlab.cancelBuild", arguments = {} })
            end, { desc = "Cancel Build" })
        end,
    }
end

M.lsp_list = vim.tbl_keys(M.lsp())

M.lsp_filetype_list = {
    "json",
    "lua",
    "markdown",
    "python",
    "rust",
    "sh",
    "tex",
}

return M
