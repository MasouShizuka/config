local variables = require("config.variables")

local M = {}

local current_path = variables.config_path .. "/lua/plugins/programming_languages_support"
for file in io.popen(("ls -pa %s | grep -v /"):format(current_path)):lines() do
    local file_without_ext = file:match("^(.+).lua$")
    if file_without_ext and file_without_ext ~= "init" then
        local current_module = "plugins.programming_languages_support"
        for _, plugin in ipairs(require(current_module .. "." .. file_without_ext)) do
            table.insert(M, plugin)
        end
    end
end

return M
