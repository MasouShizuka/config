local M = {}

--- Run a shell command and capture the output and if the command succeeded or failed
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
    if type(cmd) == "string" then cmd = { cmd } end
    local result = vim.fn.system(cmd)
    local success = vim.api.nvim_get_vvar("shell_error") == 0
    if not success and (show_error == nil or show_error) then
        vim.api.nvim_err_writeln(("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result))
    end
    return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--- Trigger an AstroNvim user event
---@param event string The event name to be appended to Astro
function M.event(event)
    vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = event, modeline = false }) end)
end

function M.diffthis()
    vim.cmd.windo("diffthis")
    vim.cmd.normal("gg")
    vim.cmd.normal("]c")
end

function M.exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok
end

function M.extra_view_toggle(update, opts)
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
                local buf = vim.api.nvim_win_get_buf(win)
                local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if filetype == config.filetype then
                    vim.api.nvim_win_close(win, false)
                    vim.api.nvim_del_augroup_by_name(config.filetype)
                    return
                end
            end
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
        width = vim.api.nvim_win_get_height(prev_win)
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
    vim.api.nvim_set_option_value("filetype", "nvim-docs-view", { buf = buf })
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
        pattern = "*",
    })
end

-- https://github.com/rbtnn/vim-ambiwidth
function M.fix_cellwidths(cica)
    vim.opt.ambiwidth = "single"
    local cellwidths = vim.fn.getcellwidths()
    local base = {
        { 0x2030, 0x203f, 2 },
        { 0x2103, 0x2103, 2 },
        { 0x2160, 0x2169, 2 },
        { 0x2170, 0x2179, 2 },
        { 0x2190, 0x2193, 2 },
        { 0x21d2, 0x21d2, 2 },
        { 0x21d4, 0x21d4, 2 },
        { 0x2266, 0x2267, 2 },
        { 0x2460, 0x24ff, 2 },
        { 0x25a0, 0x25a1, 2 },
        { 0x25b2, 0x25b3, 2 },
        { 0x25bc, 0x25bd, 2 },
        { 0x25c6, 0x25c7, 2 },
        { 0x25cb, 0x25cb, 2 },
        { 0x25cf, 0x25cf, 2 },
        { 0x2600, 0x267f, 2 },
        { 0x2690, 0x269c, 2 },
        { 0x26a0, 0x26ad, 2 },
        { 0x26b0, 0x26b1, 2 },
        { 0x26b9, 0x26b9, 2 },
        { 0x2701, 0x2709, 2 },
        { 0x270c, 0x2727, 2 },
        { 0x2729, 0x274d, 2 },
        { 0x274f, 0x2752, 2 },
        { 0x2756, 0x2756, 2 },
        { 0x2758, 0x275e, 2 },
        { 0x2761, 0x2794, 2 },
        { 0x2798, 0x279f, 2 },
        { 0x27f5, 0x27f7, 2 },
        { 0x2b05, 0x2b0d, 2 },
        { 0x303f, 0x303f, 2 },
        { 0xe62e, 0xe62e, 2 },
        { 0xf315, 0xf316, 2 },
        { 0xf31b, 0xf31c, 2 },
    }
    for _, value in ipairs(base) do
        table.insert(cellwidths, value)
    end

    if cica then
        cica = {
            { 0xe0a0,  0xe0a3,  2 },
            { 0xe0b0,  0xe0c8,  2 },
            { 0xe0ca,  0xe0ca,  2 },
            { 0xe0cc,  0xe0d2,  2 },
            { 0xe0d4,  0xe0d4,  2 },
            { 0xe200,  0xe2a9,  2 },
            { 0xe300,  0xe3e3,  2 },
            { 0xe5fa,  0xe62b,  2 },
            { 0xe700,  0xe7c5,  2 },
            { 0xf000,  0xf00e,  2 },
            { 0xf010,  0xf01e,  2 },
            { 0xf021,  0xf03e,  2 },
            { 0xf040,  0xf04e,  2 },
            { 0xf050,  0xf05e,  2 },
            { 0xf060,  0xf06e,  2 },
            { 0xf070,  0xf07e,  2 },
            { 0xf080,  0xf08e,  2 },
            { 0xf090,  0xf09e,  2 },
            { 0xf0a0,  0xf0ae,  2 },
            { 0xf0b0,  0xf0b2,  2 },
            { 0xf0c0,  0xf0ce,  2 },
            { 0xf0d0,  0xf0de,  2 },
            { 0xf0e0,  0xf0ee,  2 },
            { 0xf0f0,  0xf0fe,  2 },
            { 0xf100,  0xf10e,  2 },
            { 0xf110,  0xf11e,  2 },
            { 0xf120,  0xf12e,  2 },
            { 0xf130,  0xf13e,  2 },
            { 0xf140,  0xf14e,  2 },
            { 0xf150,  0xf15e,  2 },
            { 0xf160,  0xf16e,  2 },
            { 0xf170,  0xf17e,  2 },
            { 0xf180,  0xf18e,  2 },
            { 0xf190,  0xf19e,  2 },
            { 0xf1a0,  0xf1ae,  2 },
            { 0xf1b0,  0xf1be,  2 },
            { 0xf1c0,  0xf1ce,  2 },
            { 0xf1d0,  0xf1de,  2 },
            { 0xf1e0,  0xf1ee,  2 },
            { 0xf1f0,  0xf1fe,  2 },
            { 0xf200,  0xf20e,  2 },
            { 0xf210,  0xf21e,  2 },
            { 0xf221,  0xf23e,  2 },
            { 0xf240,  0xf24e,  2 },
            { 0xf250,  0xf25e,  2 },
            { 0xf260,  0xf26e,  2 },
            { 0xf270,  0xf27e,  2 },
            { 0xf280,  0xf28e,  2 },
            { 0xf290,  0xf29e,  2 },
            { 0xf2a0,  0xf2ae,  2 },
            { 0xf2b0,  0xf2be,  2 },
            { 0xf2c0,  0xf2ce,  2 },
            { 0xf2d0,  0xf2de,  2 },
            { 0xf2e0,  0xf2e0,  2 },
            { 0xf300,  0xf300,  2 },
            { 0xf3000, 0xf3002, 2 },
            { 0xf301,  0xf310,  2 },
            { 0xf3100, 0xf3102, 2 },
            { 0xf311,  0xf313,  2 },
            { 0xf400,  0xf4a8,  2 },
            { 0xfe0b0, 0xfe0b5, 2 },
            { 0xfe566, 0xfe568, 2 },
            { 0xff500, 0xffd46, 2 },
        }
        for _, value in ipairs(cica) do
            table.insert(cellwidths, value)
        end
    end

    vim.fn.setcellwidths(cellwidths)
end

function M.get_highlight_color(name, val)
    local hl = vim.api.nvim_get_hl(0, { name = name })

    return string.format("#%06x", hl[val])
end

--- Open a URL under the cursor with the current operating system
---@param path string The path of the file to open with the system opener
function M.system_open(path)
    local cmd
    if vim.fn.has("win32") == 1 and vim.fn.executable("explorer") == 1 then
        os.execute("start " .. path)
        return
    elseif vim.fn.has("unix") == 1 and vim.fn.executable("xdg-open") == 1 then
        cmd = { "xdg-open" }
    elseif (vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1) and vim.fn.executable("open") == 1 then
        cmd = { "open" }
    end
    if not cmd then
        vim.notify("Available system opening tool not found!", vim.log.levels.ERROR)
        return
    end

    vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand("<cfile>") }), { detach = true })
end

-- https://github.com/AndrewRadev/undoquit.vim
function M.undoquit()
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
                window_data.open_command = ("tabnext %s | %s"):format(window_data.tabpagenr, split_command)
                result = true
            end
            vim.cmd(("%swincmd w"):format(current_winnr))
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
            window_data["open_command"] = ("%stabnew"):format(vim.fn.tabpagenr() - 1)

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
            vim.cmd(("%swincmd w"):format(neighbour_win))
        end

        vim.cmd(("%s %s"):format(window_data.open_command, vim.fn.escape(vim.fn.fnamemodify(window_data.filename, ":~:."), " ")))

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

    vim.api.nvim_create_autocmd("QuitPre", {
        callback = save_window_quit_history,
        desc = "Undoquit save window quit history",
        group = vim.api.nvim_create_augroup("Undoquit", { clear = true }),
        pattern = "*",
    })

    return restore_window, restore_tab
end

return M
