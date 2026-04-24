local environment = require("utils.environment")
local path = require("utils.path")

local M = {}

---@class format_info
---@field config? conform.JobFormatterConfig|fun():conform.JobFormatterConfig
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, format_info>
local format_infos = {
    autocorrect = {
        enable = vim.fn.executable("autocorrect") == 1,
        filetype = { "markdown" },
    },
    ["clang-format"] = {
        config = {
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
        enable = vim.fn.executable("clang-format") == 1,
        filetype = { "c", "cpp" },
    },
    ruff_format = {
        enable = environment.is_ruff_exist,
        filetype = { "python" },
    },
    ruff_organize_imports = {
        enable = environment.is_ruff_exist,
        filetype = { "python" },
    },
    ["markdownlint-cli2"] = {
        config = {
            append_args = {
                "--config", path.package_config_path .. "/.markdownlint.yaml",
            },
        },
        enable = environment.is_markdownlint_cli2_exist,
        filetype = { "markdown" },
    },
    shfmt = {
        config = {
            append_args = {
                "--indent", "4",
            },
        },
        enable = vim.fn.executable("shfmt") == 1,
        filetype = { "sh" },
    },
}

---@type string[]
M.format_list = {}
---@type table<string,conform.JobFormatterConfig>
M.format_config = {}
---@type table<string,string[]>
M.formatters_by_ft = {
    markdown = { "autocorrect" },
    ["_"] = { "trim_newlines", "trim_whitespace" },
}
M.format_filetype_list = {}
for format, info in pairs(format_infos) do
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

    M.format_list[#M.format_list + 1] = format

    if info.config then
        if type(info.config) == "function" then
            M.format_config[format] = info.config()
        else
            M.format_config[format] = info.config
        end
    end

    local filetype = info.filetype or {}
    if type(filetype) == "string" then
        filetype = { filetype }
    end
    for _, ft in ipairs(filetype) do
        if M.formatters_by_ft[ft] == nil then
            M.formatters_by_ft[ft] = {}
        end
        M.formatters_by_ft[ft][#M.formatters_by_ft[ft] + 1] = format

        M.format_filetype_list[#M.format_filetype_list + 1] = ft
    end

    ::continue::
end

return M
