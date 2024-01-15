local M = {}

M.null_ls_builtins = function(null_ls)
    return {
        black = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.black)
        end,
        -- NOTE: clangd 本身带有 clang-format，但是不能从命令行传递 custom style，只能传递已有的 style
        -- 若 clangd 支持从命令行传递 custom style，则可以去除 null-ls 的 clang-format
        clang_format = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.clang_format.with({
                extra_args = {
                    "--style", "{BasedOnStyle: LLVM, AlignTrailingComments: {Kind: Always}, ColumnLimit: 10000, IndentWidth: 4}",
                },
            }))
        end,
        gitsigns = function(source_name, methods)
            null_ls.register(null_ls.builtins.code_actions.gitsigns)
        end,
        isort = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.isort.with({
                extra_args = {
                    "--multi-line", "3",
                    "--trailing-comma",
                    "--profile", "black",
                },
            }))
        end,
        shellcheck = function(source_name, methods)
            null_ls.register(null_ls.builtins.code_actions.shellcheck)
            null_ls.register(null_ls.builtins.diagnostics.shellcheck)
        end,
        shfmt = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.shfmt.with({
                extra_args = {
                    "-i", 4,
                },
            }))
        end,
    }
end

M.null_ls_builtins_list = vim.tbl_keys(M.null_ls_builtins())

return M
