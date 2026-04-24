local environment = require("utils.environment")
local path = require("utils.path")

local M = {}

---@class lint_info
---@field config? lint.Linter|fun():lint.Linter
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, lint_info>
local lint_infos = {
    ["markdownlint-cli2"] = {
        config = {
            append_args = {
                "--config", path.package_config_path .. "/.markdownlint.yaml",
            },
        },
        enable = environment.is_markdownlint_cli2_exist,
        filetype = { "markdown" },
    },
    ruff = {
        enable = vim.fn.executable("ruff") == 1,
        filetype = { "python" },
    },
    shellcheck = {
        config = {
            append_args = {
                "-e", "SC2148",
            },
        },
        enable = vim.fn.executable("shellcheck") == 1,
        filetype = { "sh" },
    },
}

---@type string[]
M.lint_list = {}
---@type table<string,lint.Linter>
M.lint_config = {}
---@type table<string,string[]>
M.linters_by_ft = {}
---@type string[]
M.lint_filetype_list = {}
for lint, info in pairs(lint_infos) do
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

    M.lint_list[#M.lint_list + 1] = lint

    if info.config then
        if type(info.config) == "function" then
            M.lint_config[lint] = info.config()
        else
            M.lint_config[lint] = info.config
        end
    end

    local filetype = info.filetype or {}
    if type(filetype) == "string" then
        filetype = { filetype }
    end
    for _, ft in ipairs(filetype) do
        if M.linters_by_ft[ft] == nil then
            M.linters_by_ft[ft] = {}
        end
        M.linters_by_ft[ft][#M.linters_by_ft[ft] + 1] = lint

        M.lint_filetype_list[#M.lint_filetype_list + 1] = ft
    end

    ::continue::
end

return M
