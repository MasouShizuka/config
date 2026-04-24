local environment = require("utils.environment")
local path = require("utils.path")

return {
    {
        "mrcjkb/rustaceanvim",
        cmd = {
            "RustLsp",
        },
        cond = not environment.is_vscode and environment.lsp_enable,
        config = function(_, opts)
            vim.g.rustaceanvim = function()
                local adapter
                if path.codelldb_extension_path then
                    adapter = require("rustaceanvim.config").get_codelldb_adapter(path.codelldb_path, path.liblldb_path)
                end

                return {
                    dap = {
                        adapter = adapter,
                    },
                }
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if ft ~= "rust" then
                        return
                    end

                    if require("utils").is_available("which-key.nvim") then
                        require("which-key").add({
                            { "<leader>ll", buffer = args.buf, group = "rust lsp", mode = "n" },
                        })
                    end
                    vim.keymap.set("n", "<leader>lld", function() vim.cmd.RustLsp("debuggables") end, { buf = args.buf, desc = "Debugging", silent = true })
                    vim.keymap.set("n", "<leader>llr", function() vim.cmd.RustLsp("runnables") end, { buf = args.buf, desc = "Runnables", silent = true })
                    vim.keymap.set("n", "<leader>llt", function() vim.cmd.RustLsp("testables") end, { buf = args.buf, desc = "Testables", silent = true })
                end,
                desc = "Rust lsp keymap",
                group = vim.api.nvim_create_augroup("RustLspKeymap", { clear = true }),
            })
        end,
        ft = {
            "rust",
        },
    },
}
