local path = require("utils.path")

local M = {}

local default_config = {
    default_colorscheme = "tokyonight",
    colorscheme_file = path.data_path .. "/colorscheme",
}
local config = vim.fn.deepcopy(default_config)

local function load_colorscheme()
    local colorscheme = require("utils").file_read(config.colorscheme_file)
    if colorscheme == nil then
        colorscheme = config.default_colorscheme
    end

    for installed_colorscheme, value in pairs(require("utils.colors").colorscheme_list) do
        if colorscheme:match(installed_colorscheme) then
            require("lazy").load({ plugins = value.package_name })
            vim.cmd.colorscheme(colorscheme)
            -- 确保触发 heirline 等 UI 颜色的更新
            vim.api.nvim_exec_autocmds("ColorScheme", {})
            break
        end
    end
end

M.setup = function(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    load_colorscheme()

    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            require("utils").file_write(config.colorscheme_file, vim.g.colors_name or "default")
        end,
        desc = "Save colorscheme to local file",
        group = vim.api.nvim_create_augroup("ColorschemeAutoSave", { clear = true }),
    })
end

return M
