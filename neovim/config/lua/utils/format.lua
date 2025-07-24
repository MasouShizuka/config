local environment = require("utils.environment")
local path = require("utils.path")

local M = {}

---@class format_info
---@field config? table
---@field download? boolean|fun():boolean
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, format_info>
local format_list = {
    -- NOTE: autocorrect 目前不在 mason 仓库中，只能手动安装
    -- 当 mason 仓库收录后解除注释
    -- autocorrect = {
    --     download = true,
    --     enable = true,
    --     filetype = { "markdown" },
    -- },
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
        download = environment.is_gcc_exist or environment.is_clang_exist or environment.is_python_exist,
        enable = environment.is_gcc_exist or environment.is_clang_exist or environment.is_python_exist,
        filetype = { "c", "cpp" },
    },
    ruff_format = {
        download = false,
        enable = environment.is_python_exist,
        filetype = { "python" },
    },
    ruff_organize_imports = {
        download = false,
        enable = environment.is_python_exist,
        filetype = { "python" },
    },
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
    shfmt = {
        config = {
            append_args = {
                "--indent", "4",
            },
        },
        download = true,
        enable = true,
        filetype = { "sh" },
    },
}

M.format_list = {}
M.format_config = {}
M.formatters_by_ft = {
    markdown = { "autocorrect" },
    ["_"] = { "trim_newlines", "trim_whitespace" },
}
M.format_filetype_list = {}
for format, info in pairs(format_list) do
    local download = info.download
    if download == nil then
        download = true
    end
    if type(download) == "function" then
        download = download()
    end
    if download then
        M.format_list[#M.format_list + 1] = format
    end

    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if enable then
        M.format_config[format] = info.config or {}

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
    end
end

return M
