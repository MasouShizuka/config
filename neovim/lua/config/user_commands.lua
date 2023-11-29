local utils = require("config.utils")
local variables = require("config.variables")

-- toggle
local is_which_key_available, which_key = pcall(require, "which-key")
if is_which_key_available then
    which_key.register({
        mode = "n",
        ["<leader>c"] = {
            name = "+user commands",
        },
    })
    which_key.register({
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
        utils.refresh_current_buf()
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
end

if not variables.is_vscode then
    -- diff
    is_which_key_available, which_key = pcall(require, "which-key")
    if is_which_key_available then
        which_key.register({
            mode = "n",
            ["<leader>cd"] = {
                name = "+diff",
            },
        })
    end

    -- diff with clipboard
    local function diff_with_clipboard()
        vim.cmd.vnew()
        vim.api.nvim_command("put!")
        utils.diffthis()
    end
    vim.api.nvim_create_user_command("DiffWithClipboard", diff_with_clipboard, { desc = "Diff with clipboard" })
    vim.keymap.set("n", "<leader>cdc", diff_with_clipboard, { desc = "Diff with clipboard", silent = true })

    -- diff with next tab
    local function diff_with_next_tab()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.tabnext()
        vim.api.nvim_command("vertical sbuffer " .. buf)
        utils.diffthis()
    end
    vim.api.nvim_create_user_command("DiffWithNextTab", diff_with_next_tab, { desc = "Diff with next tab" })
    vim.keymap.set("n", "<leader>cdn", diff_with_next_tab, { desc = "Diff with next tab", silent = true })

    -- diff with previous tab
    local function diff_with_previous_tab()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.tabprevious()
        vim.api.nvim_command("vertical sbuffer " .. buf)
        utils.diffthis()
    end
    vim.api.nvim_create_user_command("DiffWithPrevTab", diff_with_previous_tab, { desc = "Diff with previous tab" })
    vim.keymap.set("n", "<leader>cdp", diff_with_previous_tab, { desc = "Diff with previous tab", silent = true })

    -- nvim-docs-view
    vim.api.nvim_create_user_command("DocsViewToggle", function()
        utils.extra_view_toggle(function(buf, win)
            local can_hover = false
            for _, client in ipairs(vim.lsp.get_active_clients()) do
                if client.supports_method("textDocument/hover") then
                    can_hover = true
                    break
                end
            end
            if not can_hover then
                return
            end

            vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(err, result, context, config)
                if win and vim.api.nvim_win_is_valid(win) and result and result.contents then
                    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
                    markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
                    if vim.tbl_isempty(markdown_lines) then
                        return
                    end

                    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
                    vim.lsp.util.stylize_markdown(buf, markdown_lines, {})
                    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
                end
            end)
        end, {
            filetype = "nvim-docs-view",
            position = "right",
        })
    end, { desc = "Toggle nvim-docs-view" })

    -- Undoquit
    local restore_window, restore_tab = utils.undoquit()

    vim.api.nvim_create_user_command("Undoquit", restore_window, { desc = "Undo quit" })
    vim.keymap.set("n", variables.keymap["<c-s-t>"], restore_window, { desc = "Undo quit", silent = true })

    vim.api.nvim_create_user_command("UndoquitTab", restore_window, { desc = "Undo quit tab" })
    vim.keymap.set("n", "<leader>" .. variables.keymap["<c-s-t>"], restore_tab, { desc = "Undo quit tab", silent = true })
end
