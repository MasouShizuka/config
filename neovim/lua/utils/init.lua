local M = {}

function M.bool2str(bool)
    return bool and "On" or "Off"
end

function M.clear(a)
    for key, _ in pairs(a) do
        a[key] = nil
    end
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
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
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
    -- local fd = vim.uv.fs_open(file, "w", 438)
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

function M.refresh_buf(buf, timeout, timer)
    buf = buf or vim.api.nvim_get_current_buf()

    local function create_refresh_buf_autocmd()
        local augroup = string.format("Buf%sRefresh", buf)
        vim.api.nvim_create_autocmd("BufEnter", {
            buffer = buf,
            callback = function()
                M.defer(function() vim.cmd.edit() end, timeout, timer)
                vim.api.nvim_del_augroup_by_name(augroup)
            end,
            group = vim.api.nvim_create_augroup(augroup, { clear = true }),
        })
    end

    if buf ~= vim.api.nvim_get_current_buf() then
        create_refresh_buf_autocmd()
        return
    end

    M.defer(function()
        if buf == vim.api.nvim_get_current_buf() then
            vim.cmd.edit()
        else
            create_refresh_buf_autocmd()
        end
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

function M.toggle_buffer_setting(setting, callback, silent)
    silent = silent or false

    local buf = vim.api.nvim_get_current_buf()
    local buffer_enabled = vim.b[buf][setting]
    local global_enabled = vim.g[setting] or false
    if buffer_enabled == nil then
        buffer_enabled = global_enabled
    end
    local prev_enabled = buffer_enabled

    buffer_enabled = not buffer_enabled
    vim.b[buf][setting] = buffer_enabled
    local enabled = buffer_enabled

    callback(prev_enabled, enabled)

    if not silent then
        vim.notify(string.format("%s: %s", setting, M.bool2str(buffer_enabled)), vim.log.levels.INFO, { title = "Buffer" })
    end
end

function M.toggle_global_setting(setting, callback, silent)
    silent = silent or false

    local buf = vim.api.nvim_get_current_buf()
    local buffer_enabled = vim.b[buf][setting]
    local global_enabled = vim.g[setting] or false
    local prev_enabled = buffer_enabled == nil and global_enabled or buffer_enabled

    global_enabled = not global_enabled
    vim.g[setting] = global_enabled
    local enabled
    if buffer_enabled == nil then
        enabled = global_enabled
    else
        enabled = buffer_enabled
    end

    callback(global_enabled, prev_enabled, enabled)

    if not silent then
        vim.notify(string.format("%s: %s", setting, M.bool2str(global_enabled)), vim.log.levels.INFO, { title = "Global" })
    end
end

return M
