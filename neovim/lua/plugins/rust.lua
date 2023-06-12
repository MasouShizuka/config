local variables = require("config.variables")

return {
    {
        "simrat39/rust-tools.nvim",
        config = function(_, opts)
            local package_path = variables.mason_install_root_path .. "/packages/codelldb/extension"
            local codelldb_path = package_path .. "/adapter/codelldb"
            local liblldb_path = package_path .. "/lldb/bin/liblldb"
            if variables.is_windows then
                liblldb_path = package_path .. "/lldb/bin/liblldb.dll"
            elseif variables.is_mac then
                liblldb_path = package_path .. "/lldb/bin/liblldb.dylib"
            elseif variables.is_linux then
                liblldb_path = package_path .. "/lldb/bin/liblldb.so"
            end

            require("rust-tools").setup({
                dap = {
                    adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
                },
            })
        end,
        dependencies = {
            "mfussenegger/nvim-dap",
            "neovim/nvim-lspconfig",
            "nvim-lua/plenary.nvim",
        },
        enabled = not variables.is_vscode and not variables.is_wsl,
        ft = "rust",
    },
}
