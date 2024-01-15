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
        clangd = function()
            local fallbackFlags = {}
            if environment.is_windows then
                -- NOTE: 需要安装 msys2 中的 mingw-w64-ucrt-x86_64-gcc 或 mingw-w64-x86_64-gcc
                -- msys64/ucrt64/bin 或 msys64/mingw/bin 需要添加到环境变量的用户变量和系统变量的 Path 的顶部
                -- 同时需要检查是否有其他的环境变量路径是否含有 libstdc++-6.dll，若有则可能需要去除
                -- 否则 gcc 编译出的程序可能无法执行
                -- https://stackoverflow.com/questions/76495365/simple-hello-world-program-giving-segmentation-fault-in-vs-code
                fallbackFlags[#fallbackFlags + 1] = "--target=x86_64-w64-mingw32"
            end

            lspconfig.clangd.setup(vim.tbl_deep_extend("keep", {
                cmd = {
                    "clangd",
                    -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
                    "--offset-encoding=utf-16",
                },
                init_options = {
                    fallbackFlags = fallbackFlags,
                },
            }, default_config))
        end,
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
        rust_analyzer = function()
            -- 由 rustaceanvim 设置
            -- lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("keep", {}, default_config))
        end,
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
    "cpp",
    "json",
    "lua",
    "markdown",
    "python",
    "rust",
    "sh",
    "tex",
}

return M
