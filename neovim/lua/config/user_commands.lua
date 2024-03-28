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

-- toggle cursor center
if vim.g.cursor_center_enabled == nil then
    vim.g.cursor_center_enabled = false
end

vim.keymap.set("n", "<leader>ctc", function()
    utils.toggle_global_setting("cursor_center_enabled", function(global_enabled, prev_enabled, enabled)
        if enabled then
            vim.cmd("normal! zz")
        end
    end)
end, { desc = "Toggle cursor center", silent = true })
vim.keymap.set("n", "<leader>ctC", function()
    utils.toggle_buffer_setting("cursor_center_enabled", function(prev_enabled, enabled)
        if enabled then
            vim.cmd("normal! zz")
        end
    end)
end, { desc = "Toggle cursor center (buffer)", silent = true })

if environment.is_vscode then
    local vscode = require("vscode-neovim")

    -- toggle fileformat
    vim.keymap.set("n", "<leader>ctf", function() vscode.action("workbench.action.editor.changeEOL") end, { desc = "Toggle fileformat", silent = true })

    -- toggle wrap
    vim.keymap.set("n", "<leader>ctw", function() vscode.action("editor.action.toggleWordWrap") end, { desc = "Toggle wrap", silent = true })
else
    -- toggle fileformat
    local function toggle_fileformat()
        local fileformat = vim.bo.fileformat

        if fileformat == "unix" then
            fileformat = "dos"
        else
            fileformat = "unix"
        end
        vim.bo.fileformat = fileformat

        vim.cmd.write()
        utils.refresh_buf()

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
        local syntax = vim.api.nvim_get_option_value("syntax", { buf = buf })
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
        vim.api.nvim_set_option_value("syntax", syntax, { buf = buf })

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
    -- https://github.com/amrbashir/nvim-docs-view
    local function extra_view_toggle(update, opts)
        local default_config = {
            filetype = "extra-view",
            focus = false,
            height = 10,
            width = 60,
            position = "right",
        }
        local config = vim.tbl_deep_extend("force", default_config, opts)

        for group in vim.fn.execute("augroup"):gmatch("%S+") do
            if group == config.filetype then
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    if not vim.api.nvim_win_is_valid(win) then
                        goto continue
                    end

                    local buf = vim.api.nvim_win_get_buf(win)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    if ft == config.filetype then
                        vim.api.nvim_win_close(win, true)
                        vim.api.nvim_del_augroup_by_name(config.filetype)

                        break
                    end

                    ::continue::
                end

                return
            end
        end

        local prev_win = vim.api.nvim_get_current_win()

        local height = config.height
        if type(height) == "function" then
            height = config.height()
        end
        local width = config.width
        if type(width) == "function" then
            width = config.width()
        end

        if config.position == "bottom" then
            vim.api.nvim_command("bel new")
            width = vim.api.nvim_win_get_width(prev_win)
        elseif config.position == "top" then
            vim.api.nvim_command("top new")
            width = vim.api.nvim_win_get_width(prev_win)
        elseif config.position == "left" then
            vim.api.nvim_command("topleft vnew")
            height = vim.api.nvim_win_get_height(prev_win)
        else
            vim.api.nvim_command("botright vnew")
            height = vim.api.nvim_win_get_height(prev_win)
        end

        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_height(win, height)
        vim.api.nvim_win_set_width(win, width)
        vim.api.nvim_set_option_value("number", false, { win = win })
        vim.api.nvim_set_option_value("relativenumber", false, { win = win })
        vim.api.nvim_set_option_value("signcolumn", "no", { win = win })

        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
        vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
        vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
        vim.api.nvim_set_option_value("filetype", config.filetype, { buf = buf })
        vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

        if not config.focus then
            vim.api.nvim_set_current_win(prev_win)
        end

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            callback = function()
                update(buf, win)
            end,
            desc = config.filetype .. " auto update",
            group = vim.api.nvim_create_augroup(config.filetype, { clear = true }),
        })
    end
    vim.api.nvim_create_user_command("DocsViewToggle", function()
        extra_view_toggle(function(buf, win)
            local can_hover = false
            for _, client in ipairs(vim.lsp.get_clients()) do
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
    -- https://github.com/AndrewRadev/undoquit.vim
    local function undoquit(create_autocmd)
        local undoquit_stack = {}

        local function is_storable(buf)
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

            if vim.fn.buflisted(buf) == 1 and buftype == "" then
                return true
            end

            return buftype == "help"
        end

        local function real_tab_buffers()
            local real_buffers = {}
            for _, buf in ipairs(vim.fn.tabpagebuflist()) do
                if is_storable(buf) then
                    real_buffers[#real_buffers + 1] = buf
                end
            end

            return real_buffers
        end

        local function use_neighbour_window(direction, split_command, window_data)
            local current_bufnr = vim.api.nvim_get_current_buf()
            local current_winnr = vim.api.nvim_get_current_win()
            local result = false

            local function try()
                vim.cmd.wincmd(direction)
                local bufnr = vim.api.nvim_get_current_buf()
                if is_storable(bufnr) and bufnr ~= current_bufnr then
                    window_data.neighbour_buffer = vim.fn.expand("%")
                    window_data.open_command = string.format("tabnext %s | %s", window_data.tabpagenr, split_command)
                    result = true
                end
                vim.cmd(string.format("%swincmd w", current_winnr))
            end
            pcall(try)

            return result, window_data
        end

        local function get_window_restore_data()
            local window_data = {
                filename = vim.fn.expand("%:p"),
                tabpagenr = vim.fn.tabpagenr(),
                view = vim.fn.winsaveview(),
            }

            local real_buffers = real_tab_buffers()
            if #real_buffers == 1 then
                window_data["neighbour_buffer"] = ""
                window_data["open_command"] = string.format("%stabnew", vim.fn.tabpagenr() - 1)

                return window_data
            end

            local directions = {
                j = "leftabove split",
                k = "rightbelow split",
                l = "rightbelow split",
                h = "leftabove split",
            }
            for direction, split_command in pairs(directions) do
                local ok, data = use_neighbour_window(direction, split_command, window_data)
                if ok then
                    return data
                end
            end

            window_data.neighbour_buffer = ""
            window_data.open_command = "edit"

            return window_data
        end

        local function save_window_quit_history()
            if not is_storable(vim.api.nvim_get_current_buf()) then
                return
            end

            undoquit_stack[#undoquit_stack + 1] = get_window_restore_data()
        end

        local function restore_window()
            if #undoquit_stack == 0 then
                vim.notify("No closed windows to undo")
                return
            end

            local window_data = undoquit_stack[#undoquit_stack]
            table.remove(undoquit_stack, #undoquit_stack)

            local real_buffers = real_tab_buffers()
            if #real_buffers == 0 then
                window_data.open_command = "only | edit"
            end

            local neighbour_buffer = window_data.neighbour_buffer
            local neighbour_buf = vim.fn.bufnr(neighbour_buffer)
            local neighbour_win = vim.fn.bufwinnr(neighbour_buf)
            if neighbour_buffer ~= "" and neighbour_buf >= 0 and neighbour_win >= 0 then
                vim.cmd(string.format("%swincmd w", neighbour_win))
            end

            vim.cmd(string.format("%s %s", window_data.open_command, vim.fn.escape(vim.fn.fnamemodify(window_data.filename, ":~:."), " ")))

            local view = window_data.view
            if view then
                vim.fn.winrestview(view)
            end
        end

        local function restore_tab()
            if #undoquit_stack == 0 then
                vim.notify("No closed tabs to undo")
                return
            end

            local last_window = undoquit_stack[#undoquit_stack]
            local last_tab = last_window.tabpagenr
            while last_window.tabpagenr == last_tab do
                restore_window()

                if #undoquit_stack > 0 then
                    last_window = undoquit_stack[#undoquit_stack]
                else
                    break
                end

                if last_window.open_command == "1tabnew" then
                    break
                end
            end
        end

        if create_autocmd then
            vim.api.nvim_create_autocmd("QuitPre", {
                callback = save_window_quit_history,
                desc = "Undoquit save window quit history",
                group = vim.api.nvim_create_augroup("Undoquit", { clear = true }),
            })
        end

        return restore_window, restore_tab
    end
    local restore_window, restore_tab = undoquit(true)

    vim.api.nvim_create_user_command("Undoquit", restore_window, { desc = "Undo quit" })
    vim.keymap.set("n", keymap["<c-s-t>"], restore_window, { desc = "Undo quit", silent = true })

    vim.api.nvim_create_user_command("UndoquitTab", restore_window, { desc = "Undo quit tab" })
    vim.keymap.set("n", "<leader>" .. keymap["<c-s-t>"], restore_tab, { desc = "Undo quit tab", silent = true })
end
