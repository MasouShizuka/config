local path = require("utils.path")

local M = {}

-- wsl 下安装部分 lsp 后可能会存在路径错误
-- 这是因为 mason 调用了 windows 中的 npm
-- 需要安装 wsl 平台的 npm
-- https://github.com/williamboman/mason.nvim/issues/1315

---@class lsp_info
---@field config? fun(lspconfig: any, default_config: table): function
---@field download? boolean|fun():boolean
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, lsp_info>
local lsp_list = {
    bashls = {
        download = true,
        enable = true,
        filetype = { "sh" },
    },
    clangd = {
        config = function(lspconfig, default_config)
            return function()
                local fallbackFlags = {}
                if require("utils.environment").is_windows then
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
            end
        end,
        download = true,
        enable = function() return vim.fn.executable("gcc") == 1 end,
        filetype = { "c", "cpp" },
    },
    jsonls = {
        download = true,
        enable = true,
        filetype = { "json" },
    },
    lua_ls = {
        config = function(lspconfig, default_config)
            return function()
                local cwd = vim.fn.getcwd()
                if require("utils.environment").is_windows then
                    cwd = cwd:gsub("\\", "/")
                end
                if cwd == path.config_path then
                    if require("utils").is_available("lazydev.nvim") then
                        require("lazy").load({ plugins = "lazydev.nvim" })
                    end
                end

                lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", default_config, {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {
                                    "mp",
                                    "vim",
                                    "ya",
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
            end
        end,
        download = true,
        enable = true,
        filetype = { "lua" },
    },
    marksman = {
        config = function(lspconfig, default_config)
            return function()
                lspconfig.marksman.setup(vim.tbl_deep_extend("force", default_config, {
                    root_dir = function() return vim.fn.getcwd() end,
                    -- 已经使用 markdownlint-cli2 的 diagnostics，因此禁用 marksman 的 diagnostics
                    handlers = {
                        ["textDocument/publishDiagnostics"] = function() end,
                    },
                }))
            end
        end,
        download = true,
        enable = true,
        filetype = { "markdown" },
    },
    pyright = {
        config = function(lspconfig, default_config)
            return function()
                local pythonPath = path.python_path
                local python_envs_path = path.get_python_envs_path()
                if python_envs_path then
                    pythonPath = python_envs_path
                    vim.notify(("Activated:\n%s"):format(pythonPath), vim.log.levels.INFO, { title = "pyright" })
                end

                lspconfig.pyright.setup(vim.tbl_deep_extend("force", default_config, {
                    root_dir = function() return vim.fn.getcwd() end,
                    settings = {
                        pyright = {
                            -- Using Ruff's import organizer
                            disableOrganizeImports = true,
                        },
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
            end
        end,
        download = true,
        enable = function() return vim.fn.executable("python") == 1 end,
        filetype = { "python" },
    },
    rust_analyzer = {
        config = function(lspconfig, default_config)
            return function()
                if not require("utils").is_available("rustaceanvim") then
                    lspconfig.rust_analyzer.setup(vim.tbl_deep_extend("force", default_config, {}))
                end
            end
        end,
        download = true,
        enable = function() return vim.fn.executable("rustc") == 1 end,
        filetype = { "rust" },
    },
    texlab = {
        config = function(lspconfig, default_config)
            return function()
                local executable = path.sioyek_path

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
                    local client = vim.lsp.get_clients({ bufnr = 0, name = "texlab" })
                    if #client > 0 then
                        client[1]:exec_cmd({
                            title = "cleanAuxiliary",
                            command = "texlab.cleanAuxiliary",
                            arguments = { { uri = vim.uri_from_bufnr(0) } },
                        })
                    end
                end, { desc = "Clean Auxiliary" })
                vim.api.nvim_create_user_command("TexlabCleanArtifacts", function()
                    local client = vim.lsp.get_clients({ bufnr = 0, name = "texlab" })
                    if #client > 0 then
                        client[1]:exec_cmd({
                            title = "cleanArtifacts",
                            command = "texlab.cleanArtifacts",
                            arguments = { { uri = vim.uri_from_bufnr(0) } },
                        })
                    end
                end, { desc = "Clean Artifacts" })
                vim.api.nvim_create_user_command("TexlabCancelBuild", function()
                    local client = vim.lsp.get_clients({ bufnr = 0, name = "texlab" })
                    if #client > 0 then
                        client[1]:exec_cmd({
                            title = "cancelBuild",
                            command = "texlab.cancelBuild",
                            arguments = {},
                        })
                    end
                end, { desc = "Cancel Build" })
            end
        end,
        download = true,
        enable = function() return vim.fn.executable("latex") == 1 end,
        filetype = { "bib", "tex" },
    },
}

M.lsp_config = {}
M.lsp_list = {}
M.lsp_filetype_list = {}
for lsp, info in pairs(lsp_list) do
    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if enable then
        M.lsp_config[lsp] = info.config or function(lspconfig, default_config)
            return function()
                lspconfig[lsp].setup(vim.tbl_deep_extend("force", default_config, {}))
            end
        end

        local download = info.download
        if download == nil then
            download = true
        end
        if type(download) == "function" then
            download = download()
        end
        if download then
            M.lsp_list[#M.lsp_list + 1] = lsp
        end

        local filetype = info.filetype or {}
        if type(filetype) == "string" then
            filetype = { filetype }
        end
        for _, ft in ipairs(filetype) do
            M.lsp_filetype_list[#M.lsp_filetype_list + 1] = ft
        end
    end
end

return M
