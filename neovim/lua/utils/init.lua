local M = {}

function M.bool2str(bool)
    return bool and "On" or "Off"
end

--- Run a shell command and capture the output and if the command succeeded or failed
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
    if type(cmd) == "string" then
        cmd = { cmd }
    end
    local result = vim.fn.system(cmd)
    local success = vim.api.nvim_get_vvar("shell_error") == 0
    if not success and (show_error == nil or show_error) then
        vim.api.nvim_err_writeln(("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result))
    end
    return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

function M.defer(fn, timeout, timer)
    if timeout == nil then
        fn()
        return
    end

    if timer then
        vim.fn.timer_stopall()
        vim.fn.timer_start(timeout, fn)
    else
        vim.defer_fn(fn, timeout)
    end
end

function M.escape(s)
    return s:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
end

--- Trigger an AstroNvim user event
---@param event string The event name to be appended to Astro
---@param delay? boolean Whether or not to delay the event asynchronously (Default: true)
function M.event(event, delay)
    local emit_event = function()
        vim.api.nvim_exec_autocmds("User", { pattern = event, modeline = false })
    end
    if delay == false then
        emit_event()
    else
        vim.schedule(emit_event)
    end
end

function M.diffthis()
    vim.cmd.windo("diffthis")
    vim.cmd("normal! gg")
    vim.cmd("normal! ]c")
end

-- https://github.com/amrbashir/nvim-docs-view
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
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if ft == config.filetype then
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

function M.get_char_from_string(str)
    local char_list = {}
    local char_count = 0

    local len_in_byte = #str
    local i = 1
    while (i <= len_in_byte) do
        local cur_byte = str:byte(i)
        local byte_count = 1;
        if cur_byte > 0 and cur_byte <= 127 then
            byte_count = 1
        elseif cur_byte >= 192 and cur_byte < 223 then
            byte_count = 2
        elseif cur_byte >= 224 and cur_byte < 239 then
            byte_count = 3
        elseif cur_byte >= 240 and cur_byte <= 247 then
            byte_count = 4
        end

        local char = str:sub(i, i + byte_count - 1)
        char_list[#char_list + 1] = char

        i = i + byte_count
        char_count = char_count + 1
    end

    return char_count, char_list
end

function M.get_highlight(name, key)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    return string.format("#%06x", hl[key])
end

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
---@param plugin string The plugin to search for
---@return boolean available # Whether the plugin is available
function M.is_available(plugin)
    local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
    return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

function M.is_bigfile(buf)
    local max_filesize = 500 * 1024
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
        return true
    end
    return false
end

function M.is_git()
    return M.cmd({ "git", "-C", vim.fn.getcwd(), "rev-parse" }, false)
end

function M.is_longfile(buf, detect_all_lines)
    local max_linewidth = 10000
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if detect_all_lines then
        for _, line in ipairs(lines) do
            if #line > max_linewidth then
                return true
            end
        end
    else
        if #lines > 0 and #lines[1] > max_linewidth then
            return true
        end
    end
    return false
end

function M.json_save(file, data)
    local f = io.open(file, "w")
    if not f then
        return
    end

    local ok, json = pcall(vim.json.encode, data)
    if ok then
        f:write(json)
    end

    io.close(f)

    -- NOTE: 当 neovim 正式版 到 v0.10，改用以下
    -- local fd = vim.uv.fs_open(file, "w", -1)
    -- if fd == nil then
    --     return
    -- end
    --
    -- local ok, json = pcall(vim.json.encode, data)
    -- if ok then
    --     vim.uv.fs_write(fd, json, -1)
    -- end
    --
    -- vim.uv.fs_close(fd)
end

function M.json_load(file)
    if vim.fn.filereadable(file) == 0 then
        return {}
    end

    local f = io.open(file, "r")
    if not f then
        return {}
    end

    local json = f:read("*a")
    io.close(f)

    -- NOTE: 当 neovim 正式版 到 v0.10，改用以下
    -- local fd = vim.uv.fs_open(file, "r", 438)
    -- if fd == nil then
    --     return {}
    -- end
    --
    -- local stat = vim.uv.fs_fstat(fd)
    -- local json = vim.uv.fs_read(fd, stat.size, 0)
    -- vim.uv.fs_close(fd)

    local ok, data = pcall(vim.json.decode, json)
    if not ok then
        return {}
    end

    return data
end

function M.move(key, set_jumps)
    local buf = vim.api.nvim_get_current_buf()
    local keep_center = vim.b[buf].keep_center or false
    if set_jumps == nil then
        set_jumps = true
    end

    local prefix = ""
    local postfix = ""

    if keep_center then
        postfix = postfix .. "zz"
    end

    local count = vim.v.count
    if count > 0 then
        prefix = prefix .. tostring(count)
        if set_jumps then
            vim.cmd("normal! m'")
        end
    end

    if count == 0 and not vim.fn.mode():find("V") then
        vim.cmd.normal(string.format("g%s%s", key, postfix))
    else
        vim.cmd(string.format("normal! %s%s%s", prefix, key, postfix))
    end
end

function M.refresh_buf(buf, timeout, timer)
    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = buf,
        callback = function()
            M.defer(function()
                vim.cmd.edit()
            end, timeout, timer)
        end,
        once = true,
    })
end

function M.refresh_current_buf(timeout, timer)
    M.defer(function()
        vim.cmd.edit()
    end, timeout, timer)
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
function M.undoquit(create_autocmd)
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

return M
