-- undoquit
-- https://github.com/AndrewRadev/undoquit.vim

local M = {}

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

M.setup = function(opts)
    M.restore_window = restore_window
    M.restore_tab = restore_tab

    vim.api.nvim_create_user_command("Undoquit", restore_window, { desc = "Undo quit" })
    vim.api.nvim_create_user_command("UndoquitTab", restore_window, { desc = "Undo quit tab" })

    vim.api.nvim_create_autocmd("QuitPre", {
        callback = save_window_quit_history,
        desc = "Undoquit save window quit history",
        group = vim.api.nvim_create_augroup("Undoquit", { clear = true }),
    })
end

return M
