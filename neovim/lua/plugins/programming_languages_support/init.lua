local M = {}

for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/plugins/programming_languages_support/*.lua", true)) do
    local file = vim.fn.fnamemodify(path, ":t:r")
    if file ~= "init" then
        for _, plugin in ipairs(require("plugins.programming_languages_support" .. "." .. file)) do
            table.insert(M, plugin)
        end
    end
end

return M
