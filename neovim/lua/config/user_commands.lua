local variables = require("config.variables")

local ok, wk = pcall(require, "which-key")
if ok then
    wk.register({
        mode = "n",
        ["<leader>c"] = {
            name = "+user commands",
        },
    })
    wk.register({
        mode = "n",
        ["<leader>ct"] = {
            name = "+toggle",
        },
    })
end

-- toggle keep cursor center
local is_keep_cursor_center = false
local function toggle_keep_cursor_center()
    if is_keep_cursor_center then
        vim.keymap.set({ "n", "x" }, "j", "v:count == 0 && mode() !=# 'V' ? 'gj' : 'j'", { desc = "Down", expr = true, remap = true, silent = true })
        vim.keymap.set({ "n", "x" }, "k", "v:count == 0 && mode() !=# 'V' ? 'gk' : 'k'", { desc = "Up", expr = true, remap = true, silent = true })
    else
        vim.cmd.normal("zz")
        vim.keymap.set({ "n", "x" }, "j", "v:count == 0 && mode() !=# 'V' ? 'gjzz' : 'jzz'", { desc = "Down", expr = true, remap = true, silent = true })
        vim.keymap.set({ "n", "x" }, "k", "v:count == 0 && mode() !=# 'V' ? 'gkzz' : 'kzz'", { desc = "Up", expr = true, remap = true, silent = true })
    end

    is_keep_cursor_center = not is_keep_cursor_center
end
vim.api.nvim_create_user_command("ToggleKeepCursorCenter", toggle_keep_cursor_center, { desc = "Toggle keep cursor center" })
vim.keymap.set("n", "<leader>ctc", toggle_keep_cursor_center, { desc = "Toggle keep cursor center", silent = true })

if not variables.is_vscode then
    -- toggle fileformat
    local function toggle_fileformat()
        local fileformat = vim.api.nvim_get_option_value("fileformat", { scope = "local" })
        if fileformat == "dos" then
            vim.api.nvim_set_option_value("fileformat", "unix", { scope = "local" })
        else
            vim.api.nvim_set_option_value("fileformat", "dos", { scope = "local" })
        end
        vim.cmd.write()
        vim.cmd.edit()
    end
    vim.api.nvim_create_user_command("ToggleFileformat", toggle_fileformat, { desc = "Toggle fileformat" })
    vim.keymap.set("n", "<leader>ctf", toggle_fileformat, { desc = "Toggle fileformat", silent = true })

    -- toggle wrap
    local function toggle_wrap()
        local wrap = vim.api.nvim_get_option_value("wrap", { scope = "local" })
        vim.api.nvim_set_option_value("wrap", not wrap, { scope = "local" })
    end
    vim.api.nvim_create_user_command("ToggleWrap", toggle_wrap, { desc = "Toggle wrap" })
    vim.keymap.set("n", "<leader>ctw", toggle_wrap, { desc = "Toggle wrap", silent = true })

    -- diff
    local ok, wk = pcall(require, "which-key")
    if ok then
        wk.register({
            mode = "n",
            ["<leader>cd"] = {
                name = "+diff",
            },
        })
    end

    local function diff_this()
        vim.cmd.windo("diffthis")
        vim.cmd.normal("gg")
        vim.cmd.normal("]c")
    end

    local function diff_with_clipboard()
        vim.cmd.vnew()
        vim.api.nvim_command("put!")
        diff_this()
    end
    vim.api.nvim_create_user_command("DiffWithClipboard", diff_with_clipboard, { desc = "Diff with clipboard" })
    vim.keymap.set("n", "<leader>cdc", diff_with_clipboard, { desc = "Diff with clipboard", silent = true })

    local function diff_with_next_tab()
        local buffer = vim.api.nvim_get_current_buf()
        vim.cmd.tabnext()
        vim.api.nvim_command("vertical sbuffer " .. buffer)
        diff_this()
    end
    vim.api.nvim_create_user_command("DiffWithNextTab", diff_with_next_tab, { desc = "Diff with next tab" })
    vim.keymap.set("n", "<leader>cdn", diff_with_next_tab, { desc = "Diff with next tab", silent = true })

    local function diff_with_previous_tab()
        local buffer = vim.api.nvim_get_current_buf()
        vim.cmd.tabprevious()
        vim.api.nvim_command("vertical sbuffer " .. buffer)
        diff_this()
    end
    vim.api.nvim_create_user_command("DiffWithPrevTab", diff_with_previous_tab, { desc = "Diff with previous tab" })
    vim.keymap.set("n", "<leader>cdp", diff_with_previous_tab, { desc = "Diff with previous tab", silent = true })
end
