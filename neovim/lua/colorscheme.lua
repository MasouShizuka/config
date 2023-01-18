local global = require("global")
local colorscheme = "onedark"

if not vim.g.neovide then
    require("onedarkpro").setup({
        options = {
            transparency = true,
        }
    })
end

if not global.is_vscode then
    local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
    if not status_ok then
        vim.notify("colorscheme: " .. colorscheme .. " 没有找到！")
        return
    end
end
