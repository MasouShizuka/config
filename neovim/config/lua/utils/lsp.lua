local path = require("utils.path")

local M = {}

---@class lsp_info
---@field config? vim.lsp.Config|fun():vim.lsp.Config
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, lsp_info>
local lsp_infos = {
    bashls = {
        enable = vim.fn.executable("bash-language-server") == 1,
        filetype = { "sh" },
    },
    clangd = {
        config = function()
            local fallbackFlags = {}
            if require("utils.environment").is_windows then
                -- NOTE: 需要安装 C 编译器
                -- 可安装 msys2 中的 mingw-w64-ucrt-x86_64-gcc 或 mingw-w64-ucrt-x86_64-clang
                --
                -- 需要检查是否有其他的环境变量路径是否含有 libstdc++-6.dll
                -- 若有则需要去除
                -- 否则编译出的程序可能无法执行
                -- https://stackoverflow.com/questions/76495365/simple-hello-world-program-giving-segmentation-fault-in-vs-code
                fallbackFlags[#fallbackFlags + 1] = "--target=x86_64-w64-mingw32"
            end

            return {
                -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
                capabilities = {
                    offsetEncoding = "utf-16",
                },
                init_options = {
                    fallbackFlags = fallbackFlags,
                },
            }
        end,
        enable = vim.fn.executable("clangd") == 1,
        filetype = { "c", "cpp" },
    },
    jsonls = {
        enable = vim.fn.executable("vscode-json-language-server") == 1,
        filetype = { "json" },
    },
    lua_ls = {
        config = {
            on_init = function(client)
                if client.workspace_folders then
                    local workspace_path = client.workspace_folders[1].name
                    if require("utils.environment").is_windows then
                        workspace_path = workspace_path:gsub("\\", "/")
                    end
                    if
                        workspace_path ~= workspace_path.config_path
                        and (vim.uv.fs_stat(workspace_path .. "/.luarc.json") or vim.uv.fs_stat(workspace_path .. "/.luarc.jsonc"))
                    then
                        return
                    end
                end

                client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most
                        -- likely LuaJIT in the case of Neovim)
                        version = "LuaJIT",
                        -- Tell the language server how to find Lua modules same way as Neovim
                        -- (see `:h lua-module-load`)
                        path = {
                            "lua/?.lua",
                            "lua/?/init.lua",
                        },
                    },
                    -- Make the server aware of Neovim runtime files
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            -- Depending on the usage, you might want to add additional paths
                            -- here.
                            -- '${3rd}/luv/library'
                            -- '${3rd}/busted/library'
                        },
                        -- Or pull in all of 'runtimepath'.
                        -- NOTE: this is a lot slower and will cause issues when working on
                        -- your own configuration.
                        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                        -- library = {
                        --   vim.api.nvim_get_runtime_file('', true),
                        -- }
                    },
                })

                if require("utils").is_available("lazydev.nvim") and not package.loaded["lazydev"] then
                    require("lazy").load({ plugins = "lazydev.nvim" })
                end
            end,
            settings = {
                Lua = {
                    completion = {
                        callSnippet = "Replace",
                    },
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
                    },
                    hint = {
                        enable = true,
                    },
                },
            },
        },
        enable = vim.fn.executable("lua-language-server") == 1,
        filetype = { "lua" },
    },
    marksman = {
        config = {
            -- 已经使用 markdownlint-cli2 的 diagnostics，因此禁用 marksman 的 diagnostics
            handlers = {
                ["textDocument/publishDiagnostics"] = function() end,
            },
        },
        enable = vim.fn.executable("marksman") == 1,
        filetype = { "markdown" },
    },
    pyright = {
        config = function()
            local python_envs_path = path.get_python_envs_path()
            if python_envs_path ~= path.python_path then
                vim.notify(("Activated:\n%s"):format(python_envs_path), vim.log.levels.INFO, { title = "pyright" })
            end

            return {
                settings = {
                    pyright = {
                        -- Using Ruff's import organizer
                        disableOrganizeImports = true,
                    },
                    python = {
                        pythonPath = python_envs_path,
                    },
                },
            }
        end,
        enable = vim.fn.executable("pyright") == 1,
        filetype = { "python" },
    },
    rust_analyzer = {
        enable = function()
            return not require("utils").is_available("rustaceanvim") and vim.fn.executable("rust-analyzer") == 1
        end,
        filetype = { "rust" },
    },
    texlab = {
        config = function()
            return {
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
                            executable = path.sioyek_path,
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
            }
        end,
        enable = vim.fn.executable("texlab") == 1,
        filetype = { "bib", "tex" },
    },
}

M.lsp_list = {}
M.lsp_config = {}
M.lsp_filetype_list = {}
for lsp, info in pairs(lsp_infos) do
    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if not enable then
        goto continue
    end

    M.lsp_list[#M.lsp_list + 1] = lsp

    if info.config then
        if type(info.config) == "function" then
            M.lsp_config[lsp] = info.config()
        else
            M.lsp_config[lsp] = info.config
        end
    end

    local filetype = info.filetype or {}
    if type(filetype) == "string" then
        filetype = { filetype }
    end
    for _, ft in ipairs(filetype) do
        M.lsp_filetype_list[#M.lsp_filetype_list + 1] = ft
    end

    ::continue::
end

return M
