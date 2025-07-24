local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_mac = vim.fn.has("mac") == 1
M.is_linux = vim.fn.has("linux") == 1
M.is_wsl = vim.fn.has("wsl") == 1

M.is_vscode = vim.g.vscode or false

M.is_clang_exist = vim.fn.executable("clang") == 1
M.is_gcc_exist = vim.fn.executable("gcc") == 1
M.is_latex_exist = vim.fn.executable("latex") == 1
M.is_python_exist = vim.fn.executable("python") == 1
M.is_rustc_exist = vim.fn.executable("rustc") == 1

-- https://wezfurlong.org/wezterm/faq.html#how-do-i-enable-undercurl-curly-underlines
M.is_undercurl_available = not M.is_windows or vim.env.WT_SESSION or vim.env.TERM_PROGRAM == "WezTerm"

M.lsp_enable = true
M.dap_enable = true
M.format_enable = true
M.lint_enable = true
M.mason_enable = M.lsp_enable or M.dap_enable or M.format_enable or M.lint_enable

M.treesitter_enable = true

return M
