local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

local M = {}

-- wsl 下安装部分 lsp 后可能会存在路径错误
-- 这是因为 mason 调用了 windows 中的 npm
-- 需要安装 wsl 平台的 npm
-- https://github.com/williamboman/mason.nvim/issues/1315
M.lsp = function(lspconfig, default_config)
    return {
        bashls = function()
            lspconfig.bashls.setup(vim.tbl_deep_extend("force", default_config, {}))
        end,
        clangd = function()
            local fallbackFlags = {}
            if environment.is_windows then
                -- NOTE: 需要安装 gcc
                -- 可安装 msys2 中的 mingw-w64-ucrt-x86_64-gcc
                --
                -- 需要检查是否有其他的环境变量路径是否含有 libstdc++-6.dll
                -- 若有则需要去除
                -- 否则 gcc 编译出的程序可能无法执行
                -- https://stackoverflow.com/questions/76495365/simple-hello-world-program-giving-segmentation-fault-in-vs-code
                fallbackFlags[#fallbackFlags + 1] = "--target=x86_64-w64-mingw32"
            end

            lspconfig.clangd.setup(vim.tbl_deep_extend("force", default_config, {
                -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
                capabilities = {
                    offsetEncoding = "utf-16",
                },
                init_options = {
                    fallbackFlags = fallbackFlags,
                },
            }))
        end,
        jsonls = function()
            lspconfig.jsonls.setup(vim.tbl_deep_extend("force", default_config, {}))
        end,
        lua_ls = function()
            local cwd = vim.fn.getcwd()
            if environment.is_windows then
                cwd = cwd:gsub("\\", "/")
            end
            if cwd == path.config_path then
                if utils.is_available("lazydev.nvim") then
                    require("lazydev")
                end
            end

            lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", default_config, {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = {
                                "mp",
                                "vim",
                            },
                        },
                        format = {
                            defaultConfig = {
                                quote_style = "double",
                                max_line_length = "unset",
                                trailing_table_separator = "smart",
                            },
                            enable = true,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }))
        end,
        marksman = function()
            lspconfig.marksman.setup(vim.tbl_deep_extend("force", default_config, {
                root_dir = function() return vim.fn.getcwd() end,
                -- 已经使用 markdownlint-cli2 的 diagnostics，因此禁用 marksman 的 diagnostics
                handlers = {
                    ["textDocument/publishDiagnostics"] = function() end,
                },
            }))
        end,
        pyright = function()
            local pythonPath = path.python_path
            local python_envs_path = path.get_python_envs_path()
            if python_envs_path then
                pythonPath = python_envs_path
                vim.notify(("Activated:\n%s"):format(pythonPath), vim.log.levels.INFO, { title = "pyright" })
            end

            lspconfig.pyright.setup(vim.tbl_deep_extend("force", default_config, {
                root_dir = function() return vim.fn.getcwd() end,
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true,
                        },
                        pythonPath = pythonPath,
                    },
                },
            }))
        end,
        rust_analyzer = function()
            if not utils.is_available("rustaceanvim") then
                lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", default_config, {}))
            end
        end,
        texlab = function()
            local executable = "sioyek"
            if environment.is_windows then
                executable = path.scoop_app_path .. "/sioyek/current/sioyek"
            end

            lspconfig.texlab.setup(vim.tbl_deep_extend("force", default_config, {
                root_dir = function() return vim.fn.getcwd() end,
                settings = {
                    texlab = {
                        build = {
                            executable = "xelatex",
                            args = {
                                "-interaction=nonstopmode",
                                "-synctex=1",
                                "%f",
                            },
                            forwardSearchAfter = true,
                        },
                        forwardSearch = {
                            executable = executable,
                            args = {
                                "--nofocus",
                                "--reuse-window",
                                "--forward-search-file",
                                "%f",
                                "--forward-search-line",
                                "%l",
                                "%p",
                            },
                        },
                        inlayHints = {
                            labelReferences = false,
                        },
                    },
                },
            }))

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
    "bib",
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
