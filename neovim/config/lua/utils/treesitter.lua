local M = {}

---@class treesitter_info
---@field enable? boolean|fun():boolean
---@field filetype? string|string[]

---@type table<string, treesitter_info>
local treesitter_info = {
    bash = {
        enable = true,
        filetype = { "sh" },
    },
    cpp = {
        enable = function() return vim.fn.executable("g++") == 1 or vim.fn.executable("clang++") == 1 end,
        filetype = { "cpp" },
    },
    diff = {
        enable = true,
    },
    html = {
        enable = function() return require("utils").is_available("leetcode.nvim") end,
        filetype = { "html" },
    },
    python = {
        enable = function() return vim.fn.executable("python") == 1 end,
        filetype = { "python" },
    },
    regex = {
        enable = true,
    },
    rust = {
        enable = function() return vim.fn.executable("rustc") == 1 end,
        filetype = { "rust" },
    },
}

M.treesitter = {
    -- the listed parsers MUST always be installed
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
}
M.treesitter_filetype_list = {
    "c",
    "lua",
    "vim",
    "markdown",
    "help",
}
for treesitter, info in pairs(treesitter_info) do
    local enable = info.enable
    if enable == nil then
        enable = true
    end
    if type(enable) == "function" then
        enable = enable()
    end
    if enable then
        M.treesitter[#M.treesitter + 1] = treesitter

        local filetype = info.filetype or {}
        if type(filetype) == "string" then
            filetype = { filetype }
        end
        for _, ft in ipairs(filetype) do
            M.treesitter_filetype_list[#M.treesitter_filetype_list + 1] = ft
        end
    end
end

return M
