local M = {}

local function diff_with_clipboard()
    vim.cmd.vnew()
    vim.api.nvim_command("put! +")
    vim.api.nvim_buf_set_lines(0, -2, -1, true, {})
    require("utils").diffthis()
end

local function diff_with_next_tab()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd.tabnext()
    vim.api.nvim_command("vertical sbuffer " .. buf)
    require("utils").diffthis()
end

local function diff_with_previous_tab()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd.tabprevious()
    vim.api.nvim_command("vertical sbuffer " .. buf)
    require("utils").diffthis()
end

M.setup = function(opts)
    M.diff_with_clipboard = diff_with_clipboard
    M.diff_with_next_tab = diff_with_next_tab
    M.diff_with_previous_tab = diff_with_previous_tab

    vim.keymap.set("n", "<leader>cdc", diff_with_clipboard, { desc = "Diff with clipboard", silent = true })
    vim.keymap.set("n", "<leader>cdn", diff_with_next_tab, { desc = "Diff with next tab", silent = true })
    vim.keymap.set("n", "<leader>cdp", diff_with_previous_tab, { desc = "Diff with previous tab", silent = true })

    vim.api.nvim_create_user_command("DiffWithClipboard", diff_with_clipboard, { desc = "Diff with clipboard" })
    vim.api.nvim_create_user_command("DiffWithNextTab", diff_with_next_tab, { desc = "Diff with next tab" })
    vim.api.nvim_create_user_command("DiffWithPrevTab", diff_with_previous_tab, { desc = "Diff with previous tab" })
end

return M
