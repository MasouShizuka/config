local path = require("utils.path")

local M = {}

for _, file in ipairs(vim.fn.readdir(path.config_path .. "/lua/plugins/programming_languages_support", [[v:val =~ "\.lua$"]])) do
    if file == "init.lua" then
        goto continue
    end

    for _, plugin in ipairs(require("plugins.programming_languages_support." .. file:gsub("%.lua$", ""))) do
        M[#M + 1] = plugin
    end

    ::continue::
end

return M
