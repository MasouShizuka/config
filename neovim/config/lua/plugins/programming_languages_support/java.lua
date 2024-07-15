local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        "mfussenegger/nvim-jdtls",
        cmd = {
            "JdtCompile",
            "JdtSetRuntime",
            "JdtUpdateConfig",
            "JdtUpdateDebugConfig",
            "JdtUpdateHotcode",
            "JdtBytecode",
            "JdtJol",
            "JdtJshell",
            "JdtRestart",
        },
        config = function(_, opts)
            -- setup autocmd on filetype detect java
            vim.api.nvim_create_autocmd("Filetype", {
                callback = function()
                    if opts.root_dir and opts.root_dir ~= "" then
                        require("jdtls").start_or_attach(opts)
                    else
                        vim.notify("root_dir not found. Please specify a root marker", vim.log.levels.ERROR, { title = "jdtls" })
                    end
                end,
                pattern = "java", -- autocmd to start jdtls
            })
            -- create autocmd to load main class configs on LspAttach.
            -- This ensures that the LSP is fully attached.
            -- See https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    -- ensure that only the jdtls client is activated
                    if client.name == "jdtls" then
                        require("jdtls.dap").setup_dap_main_class_configs()
                    end
                end,
                pattern = "*.java",
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local is_wk_available, wk = pcall(require, "which-key")
                    if is_wk_available then
                        wk.add({
                            { "<leader>ll", buffer = args.buf, group = "java keymap", mode = "n" },
                        })
                    end

                    vim.keymap.set("n", "<leader>llt", function() require("jdtls").test_class() end, { buffer = args.buf, desc = "Test class", silent = true })
                    vim.keymap.set("n", "<leader>llT", function() require("jdtls").test_nearest_method() end, { buffer = args.buf, desc = "Test nearest method", silent = true })
                end,
                desc = "Java keymap",
                group = vim.api.nvim_create_augroup("JavaKeymap", { clear = true }),
            })
        end,
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        enabled = not environment.is_vscode,
        ft = {
            "java",
        },
        opts = function()
            -- use this function notation to build some variables
            -- local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
            -- local root_dir = require("jdtls.setup").find_root(root_markers)
            local root_dir = vim.fn.getcwd()
            -- calculate workspace dir
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
            local workspace_dir = path.data_path .. "/site/java/workspace-root/" .. project_name
            if vim.fn.isdirectory(workspace_dir) == 0 then
                vim.fn.mkdir(workspace_dir, "p")
            end

            return {
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    "-javaagent:" .. path.mason_install_root_path .. "/share/jdtls/lombok.jar",
                    "-Xms1g",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens",
                    "java.base/java.util=ALL-UNNAMED",
                    "--add-opens",
                    "java.base/java.lang=ALL-UNNAMED",
                    "-jar",
                    path.mason_install_root_path .. "/share/jdtls/plugins/org.eclipse.equinox.launcher.jar",
                    "-configuration",
                    path.mason_install_root_path .. "/share/jdtls/config",
                    "-data",
                    workspace_dir,
                },
                root_dir = root_dir,
                settings = {
                    java = {
                        eclipse = { downloadSources = true },
                        configuration = { updateBuildConfiguration = "interactive" },
                        maven = { downloadSources = true },
                        implementationsCodeLens = { enabled = true },
                        referencesCodeLens = { enabled = true },
                        inlayHints = { parameterNames = { enabled = "all" } },
                        signatureHelp = { enabled = true },
                        completion = {
                            favoriteStaticMembers = {
                                "org.hamcrest.MatcherAssert.assertThat",
                                "org.hamcrest.Matchers.*",
                                "org.hamcrest.CoreMatchers.*",
                                "org.junit.jupiter.api.Assertions.*",
                                "java.util.Objects.requireNonNull",
                                "java.util.Objects.requireNonNullElse",
                                "org.mockito.Mockito.*",
                            },
                        },
                        sources = {
                            organizeImports = {
                                starThreshold = 9999,
                                staticStarThreshold = 9999,
                            },
                        },
                    },
                },
                init_options = {
                    bundles = {
                        path.mason_install_root_path .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
                        -- unpack remaining bundles
                        (table.unpack or unpack)(vim.split(vim.fn.glob(path.mason_install_root_path .. "/share/java-test/*.jar"), "\n", {})),
                    },
                },
                handlers = {
                    ["$/progress"] = function() end, -- disable progress updates.
                },
                filetypes = { "java" },
                on_attach = function()
                    require("jdtls").setup_dap({
                        config_overrides = {
                            console = "internalConsole",
                        },
                        hotcodereplace = "auto",
                    })
                end,
            }
        end,
    },
}
