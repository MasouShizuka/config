local colors = require("utils.colors")
local path = require("utils.path")
local utils = require("utils")

local M = {}

local config = {
    default_colorscheme = "onedark",
    colorscheme_file = path.data_path .. "/colorscheme.json",
}

local function load_colorscheme()
    local data = utils.json_load(config.colorscheme_file)
    local colorscheme = data.colorscheme
    if colorscheme == nil then
        colorscheme = config.default_colorscheme
    end

    for installed_colorscheme, value in pairs(colors.colorscheme) do
        if colorscheme:match(installed_colorscheme) then
            require(value.package_name)
            break
        end
    end

    vim.cmd.colorscheme(colorscheme)
end

M.setup = function(opts)
    opts = opts or {}
    config = vim.tbl_deep_extend("force", config, opts)

    load_colorscheme()

    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            local data = {
                colorscheme = vim.g.colors_name,
            }
            utils.json_save(config.colorscheme_file, data)
        end,
        desc = "Save colorscheme to local file",
        group = vim.api.nvim_create_augroup("ColorschemeAutoSave", { clear = true }),
    })
end

return M
