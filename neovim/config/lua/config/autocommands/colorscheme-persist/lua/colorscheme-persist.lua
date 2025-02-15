local colors = require("utils.colors")
local path = require("utils.path")
local utils = require("utils")

local M = {}

local default_config = {
    default_colorscheme = "tokyonight",
    colorscheme_file = path.data_path .. "/colorscheme.json",
}

local function load_colorscheme()
    local data = utils.json_load(default_config.colorscheme_file)
    local colorscheme = data.colorscheme
    if colorscheme == nil then
        colorscheme = default_config.default_colorscheme
    end

    for installed_colorscheme, value in pairs(colors.colorscheme) do
        if colorscheme:match(installed_colorscheme) then
            require(value.package_name)
            vim.cmd.colorscheme(colorscheme)
            break
        end
    end
end

M.setup = function(opts)
    default_config = vim.tbl_deep_extend("force", default_config, opts or {})

    load_colorscheme()

    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            local data = {
                colorscheme = vim.g.colors_name or "default",
            }
            utils.json_save(default_config.colorscheme_file, data)
        end,
        desc = "Save colorscheme to local file",
        group = vim.api.nvim_create_augroup("ColorschemeAutoSave", { clear = true }),
    })
end

return M
