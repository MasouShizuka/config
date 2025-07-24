-- undoquit.vim
-- https://github.com/AndrewRadev/undoquit.vim

local M = {}

local undoquit_stack = {}

local function is_storable(buf)
    local buftype = vim.fn.getbufvar(buf, "&buftype")
    if vim.fn.buflisted(buf) == 1 and buftype == "" then
        return true
    else
        return buftype == "help"
    end
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

local function get_neighbour_window(direction)
    local current_winnr = vim.fn.winnr()
    local data = {}

    local function try()
        vim.cmd.wincmd(direction)
        local neighbour_bufnr = vim.fn.bufnr("%")

        if current_winnr == neighbour_bufnr then
            return
        end

        if not is_storable(neighbour_bufnr) then
            return
        end

        data = {
            direction = direction,
            buffer = vim.fn.expand("%"),
            height = vim.fn.winheight(0),
            width = vim.fn.winwidth(0),
        }
    end
    pcall(try)

    vim.cmd(string.format("%swincmd w", current_winnr))

    return data
end

local function get_window_restore_data()
    local data = {
        filename = vim.fn.expand("%:p"),
        tabpagenr = vim.fn.tabpagenr(),
        view = vim.fn.winsaveview(),
    }

    local real_buffers = real_tab_buffers()

    if #real_buffers == 1 then
        data["neighbour_buffer"] = ""
        data["open_command"] = string.format("%stabnew", vim.fn.tabpagenr() - 1)
        return data
    end

    local columns = vim.api.nvim_get_option_value("columns", {})
    local cmdheight = vim.api.nvim_get_option_value("cmdheight", {})
    local laststatus
    if vim.api.nvim_get_option_value("laststatus", {}) >= 1 then
        laststatus = 1
    else
        laststatus = 0
    end
    local lines = vim.api.nvim_get_option_value("lines", {})
    local is_max_width = vim.fn.winwidth(0) == columns
    local is_max_height = vim.fn.winheight(0) + cmdheight + laststatus == lines

    local neighbours = {}

    for _, direction in ipairs({ "h", "j", "k", "l" }) do
        local neighbour_window = get_neighbour_window(direction)
        if vim.fn.empty(neighbour_window) == 0 then
            neighbours[#neighbours + 1] = neighbour_window
        end
    end

    local split_command = ""

    for _, neighbour_window in ipairs(neighbours) do
        local direction = neighbour_window.direction
        local same_height = neighbour_window.height == vim.fn.winheight(0)
        local same_width = neighbour_window.width == vim.fn.winwidth(0)

        if same_height and direction == "h" then
            data.neighbour_buffer = ""
            split_command = "rightbelow vsplit"
        elseif same_width and direction == "j" then
            split_command = "leftabove split"
        elseif same_width and direction == "k" then
            split_command = "rightbelow split"
        elseif same_height and direction == "l" then
            split_command = "leftabove vsplit"
        end

        if split_command ~= "" then
            data.neighbour_buffer = neighbour_window.buffer
            data.width = neighbour_window.width
            data.height = neighbour_window.height
            break
        end
    end

    if split_command == "" and (is_max_width or is_max_height) then
        for _, neighbour_window in ipairs(neighbours) do
            local direction = neighbour_window.direction

            if is_max_height and direction == "h" then
                split_command = "rightbelow botright vsplit"
            elseif is_max_width and direction == "j" then
                split_command = "leftabove topleft split"
            elseif is_max_width and direction == "k" then
                split_command = "rightbelow botright split"
            elseif is_max_height and direction == "l" then
                split_command = "leftabove topleft vsplit"
            end

            if split_command ~= "" then
                data.neighbour_buffer = neighbour_window.buffer
                break
            end
        end
    end

    if split_command == "" and vim.fn.empty(neighbours) == 0 then
        local neighbour_window = neighbours[1]
        local direction = neighbour_window.direction

        if direction == "h" then
            split_command = "rightbelow vsplit"
        elseif direction == "j" then
            split_command = "leftabove split"
        elseif direction == "k" then
            split_command = "rightbelow split"
        elseif direction == "l" then
            split_command = "leftabove vsplit"
        end

        data.neighbour_buffer = neighbour_window.buffer
    end

    if split_command ~= "" then
        data.width = vim.fn.winwidth(0)
        data.height = vim.fn.winheight(0)
        data.open_command = string.format("tabnext %s | %s", data.tabpagenr, split_command)
    else
        data.neighbour_buffer = ""
        data.open_command = "edit"
    end

    return data
end

local function save_window_quit_history()
    if not is_storable(vim.fn.bufnr("%")) then
        return
    end

    undoquit_stack[#undoquit_stack + 1] = get_window_restore_data()
end

local function restore_window()
    if vim.fn.empty(undoquit_stack) == 1 then
        vim.notify("No closed windows to undo")
        return
    end

    local window_data = undoquit_stack[#undoquit_stack]
    table.remove(undoquit_stack, #undoquit_stack)
    local real_buffers = real_tab_buffers()

    if #real_buffers == 0 then
        window_data.open_command = "only | edit"
    end

    if window_data.neighbour_buffer ~= "" and vim.fn.bufnr(window_data.neighbour_buffer) >= 0 then
        local max_winid = vim.fn.max(vim.fn.win_findbuf(vim.fn.bufnr(window_data.neighbour_buffer)))
        if max_winid > 0 then
            vim.fn.win_gotoid(max_winid)
        end
    end

    vim.cmd(string.format("%s %s", window_data.open_command, vim.fn.escape(vim.fn.fnamemodify(window_data.filename, ":~:."), " ")))

    local view = window_data.view
    if view then
        vim.fn.winrestview(view)
    end

    local height = window_data.height
    if height then
        vim.cmd(string.format("resize %s", height))
    end

    local width = window_data.width
    if width then
        vim.cmd(string.format("vertical resize %s", width))
    end
end

local function restore_tab()
    if vim.fn.empty(undoquit_stack) == 1 then
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
