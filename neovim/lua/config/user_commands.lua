local variables = require("config.variables")

if not variables.is_vscode then
    -- Diff
    local function diff_within_tab()
        vim.cmd.windo("diffthis")
        vim.cmd.normal("gg")
        vim.cmd.normal("]c")
    end
    vim.api.nvim_create_user_command("DiffWithClipborad", function()
        vim.cmd.vnew()
        vim.api.nvim_command("put!")
        diff_within_tab()
    end, { desc = "Diff with clipboard" })
    vim.api.nvim_create_user_command("DiffWithNextTab", function()
        local buffer = vim.api.nvim_get_current_buf()
        vim.cmd.tabnext()
        vim.api.nvim_command("vertical sbuffer " .. buffer)
        diff_within_tab()
    end, { desc = "Diff with previous tab" })
    vim.api.nvim_create_user_command("DiffWithPrevTab", function()
        local buffer = vim.api.nvim_get_current_buf()
        vim.cmd.tabprevious()
        vim.api.nvim_command("vertical sbuffer " .. buffer)
        diff_within_tab()
    end, { desc = "Diff with previous tab" })
end
