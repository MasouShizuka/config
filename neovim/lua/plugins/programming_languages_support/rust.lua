local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

return {
    {
        "mrcjkb/rustaceanvim",
        cmd = {
            "RustLsp",
        },
        config = function(_, opts)
            vim.g.rustaceanvim = function()
                local rust_analyzer_path = path.mason_install_root_path .. "/packages/rust-analyzer/rust-analyzer"
                if environment.is_windows then
                    rust_analyzer_path = rust_analyzer_path .. ".exe"
                end

                local package_path = path.mason_install_root_path .. "/packages/codelldb/extension"
                local codelldb_path = package_path .. "/adapter/codelldb"
                local liblldb_path = package_path .. "/lldb/lib/liblldb"
                if environment.is_windows then
                    codelldb_path = codelldb_path .. ".exe"
                    liblldb_path = package_path .. "/lldb/bin/liblldb.dll"
                elseif environment.is_mac then
                    liblldb_path = liblldb_path .. ".dylib"
                elseif environment.is_linux then
                    liblldb_path = liblldb_path .. ".so"
                end

                local cfg = require("rustaceanvim.config")
                return {
                    server = {
                        cmd = function()
                            return { rust_analyzer_path }
                        end,
                    },
                    dap = {
                        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
                    },
                }
            end
        end,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        enabled = not environment.is_vscode,
        ft = "rust",
    },

    -- {
    --     "simrat39/rust-tools.nvim",
    --     config = function(_, opts)
    --         local package_path = path.mason_install_root_path .. "/packages/codelldb/extension"
    --         local codelldb_path = package_path .. "/adapter/codelldb"
    --         local liblldb_path = package_path .. "/lldb/lib/liblldb"
    --         if environment.is_windows then
    --             codelldb_path = codelldb_path .. ".exe"
    --             liblldb_path = package_path .. "/lldb/bin/liblldb.dll"
    --         elseif environment.is_mac then
    --             liblldb_path = liblldb_path .. ".dylib"
    --         elseif environment.is_linux then
    --             liblldb_path = liblldb_path .. ".so"
    --         end

    --         require("rust-tools").setup({
    --             dap = {
    --                 adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
    --             },
    --         })
    --     end,
    --     dependencies = {
    --         "mfussenegger/nvim-dap",
    --         "neovim/nvim-lspconfig",
    --         "nvim-lua/plenary.nvim",
    --     },
    --     enabled = not environment.is_vscode,
    --     ft = "rust",
    -- },
}
