local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_mac = vim.fn.has("mac") == 1
M.is_linux = vim.fn.has("linux") == 1
M.is_wsl = vim.fn.has("wsl") == 1

M.is_vscode = vim.g.vscode or false

M.is_markdownlint_cli2_exist = vim.fn.executable("markdownlint-cli2") == 1
M.is_ruff_exist = vim.fn.executable("ruff") == 1

-- https://wezfurlong.org/wezterm/faq.html#how-do-i-enable-undercurl-curly-underlines
M.is_undercurl_available = not M.is_windows or vim.env.WT_SESSION or vim.env.TERM_PROGRAM == "WezTerm"

M.lsp_enable = true
M.dap_enable = true
M.format_enable = true
M.lint_enable = true

M.treesitter_enable = true

return M
