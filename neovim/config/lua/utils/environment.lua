local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_mac = vim.fn.has("mac") == 1
M.is_linux = vim.fn.has("linux") == 1
M.is_wsl = vim.fn.has("wsl") == 1

M.is_vscode = vim.g.vscode or false
M.is_neovide = vim.g.neovide or false

-- https://wezfurlong.org/wezterm/faq.html#how-do-i-enable-undercurl-curly-underlines
M.is_undercurl_available = not M.is_windows or M.is_neovide or vim.env.TERM_PROGRAM == "WindowsTerminal"

return M
