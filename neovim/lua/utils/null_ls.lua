local M = {}

M.null_ls_builtins = function(null_ls)
    return {
        black = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.black.with({
                extra_args = {
                    "--line-length", "120",
                },
            }))
        end,
        -- NOTE: clangd 本身带有 clang-format，但是不能传递 custom style，只能通过 --fallback-style 传递预定义的 style
        -- 若 clangd 支持从命令行传递 custom style，则去除 clang-format
        clang_format = function(source_name, methods)
            local style = {
                "BasedOnStyle: LLVM",
                "AlignArrayOfStructures: Right",
                "AlignTrailingComments: {Kind: Always}",
                "ColumnLimit: 10000",
                "IndentWidth: 4",
                "PointerAlignment: Left",
            }
            local style_str = "{"
            for index, value in ipairs(style) do
                style_str = style_str .. value
                if index ~= #style then
                    style_str = style_str .. ", "
                end
            end
            style_str = style_str .. "}"

            null_ls.register(null_ls.builtins.formatting.clang_format.with({
                extra_args = {
                    "--style", style_str,
                },
            }))
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
        -- bashls 可通过 shellcheckPath 启用 shellcheck
        shellcheck = function(source_name, methods) end,
        shfmt = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.shfmt.with({
                extra_args = {
                    "-i", 4,
                },
                filetypes = {
                    "sh",
                    "zsh",
                },
            }))
        end,
    }
end

M.null_ls_builtins_list = vim.tbl_keys(M.null_ls_builtins())

return M
