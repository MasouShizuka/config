local environment = require("utils.environment")
local path = require("utils.path")

local M = {}

---@class lint_info
---@field config? table
---@field download? boolean|fun():boolean
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, lint_info>
local lint_list = {
    ["markdownlint-cli2"] = {
        config = {
            append_args = {
                "--config", path.package_config_path .. "/.markdownlint.yaml",
            },
        },
        download = true,
        enable = true,
        filetype = { "markdown" },
    },
    ruff = {
        download = environment.is_python_exist,
        enable = environment.is_python_exist,
        filetype = { "python" },
    },
    shellcheck = {
        config = {
            append_args = {
                "-e", "SC2148",
            },
        },
        download = true,
        enable = true,
        filetype = { "sh" },
    },
}

M.lint_list = {}
M.lint_config = {}
M.linters_by_ft = {}
M.lint_filetype_list = {}
for lint, info in pairs(lint_list) do
    local download = info.download
    if download == nil then
        download = true
    end
    if type(download) == "function" then
        download = download()
    end
    if download then
        M.lint_list[#M.lint_list + 1] = lint
    end

    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if enable then
        M.lint_config[lint] = info.config or {}

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
    end
end

return M
