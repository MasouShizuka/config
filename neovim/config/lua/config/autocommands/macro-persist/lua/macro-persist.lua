local path = require("utils.path")
local utils = require("utils")

local M = {}

local default_config = {
    macro_file = path.data_path .. "/macro.json",
}

M.setup = function(opts)
    default_config = vim.tbl_deep_extend("force", default_config, opts or {})

    local data = utils.json_load(default_config.macro_file)
    for key, value in pairs(data) do
        vim.fn.setreg(key, value)
    end

    vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
            local regcontents = vim.v.event["regcontents"]
            if regcontents == "" then
                return
            end

            local data = utils.json_load(default_config.macro_file)
            data[vim.fn.reg_recording()] = regcontents
            utils.json_save(default_config.macro_file, data)
        end,
        desc = "Save macro to local file",
        group = vim.api.nvim_create_augroup("MacroAutoSave", { clear = true }),
    })
end

return M
