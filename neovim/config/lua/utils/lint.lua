local path = require("utils.path")

local M = {}

M.lint = {
    ["markdownlint-cli2"] = {
        args = {
            "--config", path.package_config_path .. "/.markdownlint.yaml",
        },
    },
    shellcheck = {
        args = {
            "--format", "json",
            "-",
            "-e", "SC2148",
        },
    },
}

M.lint_list = vim.tbl_keys(M.lint)

M.linters_by_ft = {
    markdown = { "markdownlint-cli2" },
    sh = { "shellcheck" },
}

M.lint_filetype_list = vim.tbl_keys(M.linters_by_ft)

return M
