local global = require("global")

if not global.is_vscode then
    local colorscheme = "onedark"

    local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
    if not status_ok then
        vim.notify("colorscheme: " .. colorscheme .. " 没有找到！")
        return
    end
end
