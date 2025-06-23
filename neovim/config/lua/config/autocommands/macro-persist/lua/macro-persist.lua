local path = require("utils.path")

local M = {}

local default_config = {
    macro_file = path.data_path .. "/macro.json",
}
local config = vim.fn.deepcopy(default_config)

M.setup = function(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    local utils = require("utils")

    local data = utils.json_read(config.macro_file)
    for key, value in pairs(data) do
        vim.fn.setreg(key, value)
    end

    vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
            local regcontents = vim.v.event["regcontents"]
            if regcontents == "" then
                return
            end

            local data = utils.json_read(config.macro_file)
            data[vim.fn.reg_recording()] = regcontents
            utils.json_write(config.macro_file, data)
        end,
        desc = "Save macro to local file",
        group = vim.api.nvim_create_augroup("MacroAutoSave", { clear = true }),
    })
end

return M
