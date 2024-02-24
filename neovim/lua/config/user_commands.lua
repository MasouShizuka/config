local environment = require("utils.environment")
local keymap = require("utils.keymap")
local utils = require("utils")

local is_which_key_available, which_key = pcall(require, "which-key")
if is_which_key_available then
    which_key.register({
        mode = "n",
        ["<leader>c"] = {
            name = "+user commands",
        },
    })
end

-- toggle
if is_which_key_available then
    which_key.register({
        mode = "n",
        ["<leader>ct"] = {
            name = "+toggle",
        },
    })
end

-- toggle keep cursor center
local function toggle_keep_cursor_center()
    local buf = vim.api.nvim_get_current_buf()
    local keep_center = vim.b[buf].keep_center or false

    keep_center = not keep_center
    vim.b[buf].keep_center = keep_center

    if keep_center then
        vim.cmd("normal! zz")
    end

    vim.notify(string.format("Keep Cursor Center: %s", utils.bool2str(keep_center)), vim.log.levels.INFO, { title = "Buffer" })
end
vim.api.nvim_create_user_command("ToggleKeepCursorCenter", toggle_keep_cursor_center, { desc = "Toggle keep cursor center" })
vim.keymap.set("n", "<leader>ctc", toggle_keep_cursor_center, { desc = "Toggle keep cursor center", silent = true })

if environment.is_vscode then
    local vscode = require("vscode-neovim")

    -- toggle fileformat
    local function toggle_fileformat()
        vscode.action("workbench.action.editor.changeEOL")
    end
    vim.api.nvim_create_user_command("ToggleFileformat", toggle_fileformat, { desc = "Toggle fileformat" })
    vim.keymap.set("n", "<leader>ctf", toggle_fileformat, { desc = "Toggle fileformat", silent = true })

    -- toggle wrap
    local function toggle_wrap()
        vscode.action("editor.action.toggleWordWrap")
    end
    vim.api.nvim_create_user_command("ToggleWrap", toggle_wrap, { desc = "Toggle wrap" })
    vim.keymap.set("n", "<leader>ctw", toggle_wrap, { desc = "Toggle wrap", silent = true })
else
    -- toggle fileformat
    local function toggle_fileformat()
        local fileformat = vim.api.nvim_get_option_value("fileformat", { scope = "local" })

        if fileformat == "unix" then
            fileformat = "dos"
        else
            fileformat = "unix"
        end
        vim.api.nvim_set_option_value("fileformat", fileformat, { scope = "local" })

        vim.cmd.write()
        utils.refresh_current_buf()

        vim.notify(string.format("Fileformat: %s", fileformat), vim.log.levels.INFO, { title = "Buffer" })
    end
    vim.api.nvim_create_user_command("ToggleFileformat", toggle_fileformat, { desc = "Toggle fileformat" })
    vim.keymap.set("n", "<leader>ctf", toggle_fileformat, { desc = "Toggle fileformat", silent = true })

    -- toggle spell
    local function toggle_spell()
        local spell = vim.api.nvim_get_option_value("spell", { scope = "local" })

        spell = not spell
        vim.api.nvim_set_option_value("spell", spell, { scope = "local" })

        vim.notify(string.format("Spell: %s", utils.bool2str(spell)), vim.log.levels.INFO, { title = "Buffer" })
    end
    vim.api.nvim_create_user_command("ToggleSpell", toggle_spell, { desc = "Toggle spell" })
    vim.keymap.set("n", "<leader>cts", toggle_spell, { desc = "Toggle spell", silent = true })

    -- toggle syntax
    local function toggle_syntax()
        local buf = vim.api.nvim_get_current_buf()
        local syntax = vim.bo[buf].syntax
        if syntax ~= "on" and syntax ~= "off" then
            syntax = "on"
        end

        local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
        local is_treesitter_available = ts_avail and parsers.has_parser()
        if syntax == "on" then
            if is_treesitter_available then
                vim.treesitter.stop(buf)
            end
            syntax = "off"
        else
            if is_treesitter_available then
                vim.treesitter.start(buf)
            end
            syntax = "on"
        end
        vim.bo[buf].syntax = syntax

        vim.notify(string.format("Syntax: %s", syntax), vim.log.levels.INFO, { title = "Buffer" })
    end
    vim.api.nvim_create_user_command("ToggleSyntax", toggle_spell, { desc = "Toggle syntax" })
    vim.keymap.set("n", "<leader>ctS", toggle_syntax, { desc = "Toggle syntax", silent = true })

    -- toggle wrap
    local function toggle_wrap()
        local wrap = vim.api.nvim_get_option_value("wrap", { scope = "local" })

        wrap = not wrap
        vim.api.nvim_set_option_value("wrap", wrap, { scope = "local" })

        vim.notify(string.format("Wrap: %s", utils.bool2str(wrap)), vim.log.levels.INFO, { title = "Buffer" })
    end
    vim.api.nvim_create_user_command("ToggleWrap", toggle_wrap, { desc = "Toggle wrap" })
    vim.keymap.set("n", "<leader>ctw", toggle_wrap, { desc = "Toggle wrap", silent = true })
end

if not environment.is_vscode then
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

            vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(err, result, ctx, config)
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

    -- undoquit
    local restore_window, restore_tab = utils.undoquit(true)

    vim.api.nvim_create_user_command("Undoquit", restore_window, { desc = "Undo quit" })
    vim.keymap.set("n", keymap["<c-s-t>"], restore_window, { desc = "Undo quit", silent = true })

    vim.api.nvim_create_user_command("UndoquitTab", restore_window, { desc = "Undo quit tab" })
    vim.keymap.set("n", "<leader>" .. keymap["<c-s-t>"], restore_tab, { desc = "Undo quit tab", silent = true })
end
