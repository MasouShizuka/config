local path = require("utils.path")

local M = {}

M.format = {
    -- NOTE: autocorrect 目前不在 mason 仓库中，只能通过 scoop 安装
    -- 当 mason 仓库收录时，解除注释
    -- autocorrect = false,
    black = {
        append_args = {
            "--line-length", "120",
        },
    },
    ["clang-format"] = {
        append_args = function(self, ctx)
            local style = {
                "BasedOnStyle: LLVM",
                "BreakAfterJavaFieldAnnotations: True",
                "AlignArrayOfStructures: Right",
                "AlignTrailingComments: {Kind: Always}",
                "ColumnLimit: 0",
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

            return {
                "--style", style_str,
            }
        end,
    },
    isort = {
        append_args = {
            "--multi-line", "3",
            "--trailing-comma",
            "--profile", "black",
        },
    },
    ["markdownlint-cli2"] = {
        append_args = {
            "--config", path.config_path .. "/lua/config/package/.markdownlint.yaml",
        },
    },
    shfmt = {
        append_args = {
            "--indent", "4",
        },
    },
}

M.format_list = vim.tbl_keys(M.format)

M.formatters_by_ft = {
    cpp = { "clang-format" },
    java = { "clang-format" },
    markdown = { "autocorrect", "markdownlint-cli2" },
    python = { "black", "isort" },
    sh = { "shfmt" },
    zsh = { "shfmt" },
}

M.format_filetype_list = vim.tbl_keys(M.formatters_by_ft)

return M
