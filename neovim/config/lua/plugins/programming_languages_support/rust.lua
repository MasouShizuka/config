local environment = require("utils.environment")
local path = require("utils.path")

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
                        cmd = { rust_analyzer_path },
                    },
                    dap = {
                        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
                    },
                }
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    if require("utils").is_available("which-key.nvim") then
                        require("which-key").add({
                            { "<leader>ll", buffer = args.buf, group = "rust keymap", mode = "n" },
                        })
                    end

                    vim.keymap.set("n", "<leader>lld", function() vim.cmd.RustLsp("debuggables") end, { buffer = args.buf, desc = "Debugging", silent = true })
                    vim.keymap.set("n", "<leader>llr", function() vim.cmd.RustLsp("runnables") end, { buffer = args.buf, desc = "Runnables", silent = true })
                    vim.keymap.set("n", "<leader>llt", function() vim.cmd.RustLsp("testables") end, { buffer = args.buf, desc = "Testables", silent = true })
                end,
                desc = "Rust keymap",
                group = vim.api.nvim_create_augroup("RustKeymap", { clear = true }),
            })
        end,
        enabled = not environment.is_vscode and environment.lsp_enable,
        ft = {
            "rust",
        },
    },
}
