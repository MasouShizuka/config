local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_mac = vim.fn.has("mac") == 1
M.is_linux = vim.fn.has("linux") == 1
M.is_wsl = vim.fn.has("wsl") == 1
M.is_vscode = vim.g.vscode or false

return M
