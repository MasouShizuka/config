local M = {}

--- Convert bool to string
---@param bool boolean
function M.bool2str(bool)
    if bool then
        return "On"
    else
        return "Off"
    end
end

--- Create a once autocmd
---@param event string|string[]
---@param opts? vim.api.keyset.create_autocmd
---@return integer
function M.create_once_autocmd(event, opts)
    opts = opts or {}
    opts.once = true

    local id

    local callback = opts.callback
    if callback and type(callback) == "function" then
        opts.callback = function(args)
            callback(args)
            vim.api.nvim_del_autocmd(id)
        end
    end

    id = vim.api.nvim_create_autocmd(event, opts)
    return id
end

---@class defer_fn_opts
---@field timeout? number
---@field use_timer? boolean

--- Delay execution of a function
---@param fn function
---@param opts? defer_fn_opts
function M.defer_fn(fn, opts)
    opts = opts or {}

    local timeout = opts.timeout
    if timeout == nil or timeout == 0 then
        fn()
        return
    end
    local use_timer = opts.use_timer

    if use_timer then
        vim.fn.timer_stopall()
        vim.fn.timer_start(timeout, fn)
    else
        vim.defer_fn(fn, timeout)
    end
end

--- Delay execution of a function in a buf
---@param buf? integer
---@param fn function
---@param opts? defer_fn_opts
function M.defer_buf_fn(buf, fn, opts)
    buf = buf or vim.api.nvim_get_current_buf()

    local function create_buf_autocmd()
        M.create_once_autocmd("BufEnter", {
            buffer = buf,
            callback = function()
                M.defer_buf_fn(buf, fn, opts)
            end,
        })
    end

    if vim.api.nvim_get_current_buf() ~= buf then
        create_buf_autocmd()
        return
    end

    M.defer_fn(function()
        if vim.api.nvim_get_current_buf() == buf then
            fn()
        else
            create_buf_autocmd()
        end
    end, opts)
end

---@class defer_fn_with_condition_opts
---@field condition? fun(): boolean
---@field max_count? integer
---@field timeout? integer

--- Delays execution of a function until condition returns true
---@param fn function
---@param opts? defer_fn_with_condition_opts
function M.defer_fn_with_condition(fn, opts)
    opts = opts or {}

    local condition = opts.condition
    if type(condition) ~= "function" then
        condition = function() return false end
    end
    local max_count = opts.max_count or 10
    local timeout = opts.timeout or 50

    local count = 0

    local func_wrapper
    func_wrapper = function()
        M.defer_fn(function()
            if condition() or count >= max_count then
                return
            end

            fn()

            count = count + 1
            func_wrapper()
        end, { timeout = timeout, use_timer = false })
    end
    func_wrapper()
end

--- Show a diffthis window
function M.diffthis()
    vim.cmd.windo("diffthis")
    vim.cmd.normal({ "gg", bang = true })
    vim.cmd.normal({ "]c", bang = true })
end

--- escape special characters in string
function M.escape(s)
    return s:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
end

--- Read a file's content
---@param file string
---@return string|nil
function M.file_read(file)
    if vim.fn.filereadable(file) == 0 then
        return nil
    end

    local fd = vim.uv.fs_open(file, "r", 438)
    if fd == nil then
        return nil
    end

    local stat = vim.uv.fs_fstat(fd)
    local data = vim.uv.fs_read(fd, stat.size, 0)
    vim.uv.fs_close(fd)

    return data
end

--- Write content to a file
---@param file string
---@param data string
---@return boolean
function M.file_write(file, data)
    local fd = vim.uv.fs_open(file, "w", 438)
    if fd == nil then
        return false
    end

    vim.uv.fs_write(fd, data, -1)
    vim.uv.fs_close(fd)

    return true
end

--- Get a char list from str
---@param str string
---@return string[]
function M.get_char_from_string(str)
    local char_list = {}

    local len_in_byte = #str
    local i = 1
    while (i <= len_in_byte) do
        local byte_count = 1;

        local cur_byte = str:byte(i)
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
    end

    return char_list
end

---@class setting_condition_opts
---@field buf? integer

--- Get the status of a setting
---@param setting string
---@param opts? setting_condition_opts
---@return boolean
function M.get_setting_condition(setting, opts)
    opts = opts or {}
    local buf = opts.buf or vim.api.nvim_get_current_buf()

    local enabled
    if vim.b[buf][setting] == nil then
        enabled = vim.g[setting]
    else
        enabled = vim.b[buf][setting]
    end
    return enabled
end

--- Get the windows path of an environment variable from wsl
---@param ev string
---@return string|nil
function M.get_windows_path_from_wsl(ev)
    local res = vim.system({ "cmd.exe", "/c", string.format("echo %%%s%%", ev) }, { text = true }):wait()
    if res.code ~= 0 then
        return nil
    end

    res = vim.system({ "wslpath", res.stdout }, { text = true }):wait()
    if res.code ~= 0 then
        return nil
    end

    return vim.trim(res.stdout)
end

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
---@param plugin string The plugin to search for
---@return boolean available # Whether the plugin is available
function M.is_available(plugin)
    local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
    return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

--- Check if a buf is bigfile
---@param buf? integer
---@return boolean
function M.is_bigfile(buf)
    buf = buf or vim.api.nvim_get_current_buf()

    local max_filesize = 1.5 * 1024 * 1024
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
        return true
    end
    return false
end

--- Check if cwd is a git repo
---@return boolean
function M.is_git()
    return vim.system({ "git", "-C", vim.fn.getcwd(), "rev-parse" }):wait().code == 0
end

--- Check if a buf is longfile
---@param buf? integer
---@param detect_all_lines? boolean
---@return boolean
function M.is_longfile(buf, detect_all_lines)
    buf = buf or vim.api.nvim_get_current_buf()
    detect_all_lines = detect_all_lines or false

    local max_linewidth = 1000
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

--- Read a json file's content
---@param file string
---@return table
function M.json_read(file)
    local json = M.file_read(file)
    if json == nil then
        return {}
    end

    local ok, data = pcall(vim.json.decode, json)
    if not ok then
        return {}
    end

    return data
end

--- Write content to a json file
---@param file string
---@param data table
---@return boolean
function M.json_write(file, data)
    local ok, json = pcall(vim.json.encode, data)
    if not ok then
        return false
    end

    return M.file_write(file, json)
end

--- Refresh a buf
---@param buf? integer
---@param opts? defer_fn_opts
function M.refresh_buf(buf, opts)
    M.defer_buf_fn(buf, function() vim.cmd.edit() end, opts)
end

--- Set a highlight with "ColorScheme" event autocmd
---@param ns_id integer
---@param name string
---@param val vim.api.keyset.highlight|fun(): vim.api.keyset.highlight
function M.set_hl(ns_id, name, val)
    local function set_hl()
        if type(val) == "function" then
            vim.api.nvim_set_hl(ns_id, name, val())
        else
            vim.api.nvim_set_hl(ns_id, name, val)
        end
    end

    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            set_hl()
        end,
    })
end

---@class keymap
---@field buf? integer
---@field keys string
---@field mode? string|string[]

---@class scope_opts
---@field keymap keymap
---@field opts? setting_opts

---@class setting_toggle_opts
---@field default? boolean
---@field init? function
---@field b? scope_opts
---@field g? scope_opts

--- Set the toggle of a setting
---@param setting string
---@param opts? setting_toggle_opts
function M.set_setting_toggle(setting, opts)
    opts = opts or {}

    local default = opts.default or false
    local init = opts.init
    local g = opts.g
    local b = opts.b

    if vim.g[setting] == nil then
        vim.g[setting] = default
    end

    if type(init) == "function" then
        init()
    end

    if b then
        local local_keymap = b.keymap
        local local_opts = b.opts or {}

        if M.is_available("snacks.nvim") then
            require("snacks").toggle.new({
                id = setting .. "_buffer",
                name = setting .. " (buffer)",
                get = function()
                    local buf = local_keymap.buf or vim.api.nvim_get_current_buf()
                    if vim.b[buf][setting] == nil then
                        return vim.g[setting]
                    end
                    return vim.b[buf][setting]
                end,
                set = function(state) M.toggle_buffer_setting(setting, vim.tbl_deep_extend("force", local_opts, { notify = false })) end,
            }):map(local_keymap.keys, { buffer = local_keymap.buf, mode = local_keymap.mode or "n" })
        else
            vim.keymap.set(
                local_keymap.mode or "n",
                local_keymap.keys,
                function() M.toggle_buffer_setting(setting, local_opts) end,
                { buffer = local_keymap.buf, desc = "Toggle " .. setting .. " (buffer)", silent = true }
            )
        end
    end

    if g then
        local global_keymap = g.keymap
        local global_opts = g.opts or {}

        if M.is_available("snacks.nvim") then
            require("snacks").toggle.new({
                id = setting .. "_global",
                name = setting .. " (global)",
                get = function() return vim.g[setting] end,
                set = function(state) M.toggle_global_setting(setting, vim.tbl_deep_extend("force", global_opts, { notify = false })) end,
            }):map(global_keymap.keys, { buffer = global_keymap.buf, mode = global_keymap.mode or "n" })
        else
            vim.keymap.set(
                global_keymap.mode or "n",
                global_keymap.keys,
                function() M.toggle_global_setting(setting, global_opts) end,
                { buffer = global_keymap.buf, desc = "Toggle " .. setting, silent = true }
            )
        end
    end
end

--- Clear a table
---@param a table
function M.table_clear(a)
    for key, _ in pairs(a) do
        a[key] = nil
    end
end

--- Concat tables
---@param a table
---@vararg table
---@return table
function M.table_concat(a, ...)
    local ts = { ... }
    if #ts == 0 then
        return a
    end

    local new = {}
    vim.list_extend(new, a)
    for _, t in ipairs(ts) do
        vim.list_extend(new, t)
    end
    return new
end

---@class option_opts
---@field callback? function
---@field global? boolean
---@field list? any[]
---@field notify? boolean

--- Toggle a option
---@param option string
---@param opts option_opts
function M.toggle_option(option, opts)
    opts = opts or {}

    local callback = opts.callback
    local global = opts.global or false
    local list = opts.list or {}
    local notify
    if opts.notify == nil then
        notify = true
    else
        notify = opts.notify
    end

    local option_opts = { scope = global and "global" or "local" }
    local prev_enabled = vim.api.nvim_get_option_value(option, option_opts)

    local enabled
    if #list > 0 then
        local prev_index = 1
        for index, value in ipairs(list) do
            if value == prev_enabled then
                prev_index = index
                break
            end
        end

        local index = prev_index + 1
        if index > #list then
            index = 1
        end

        enabled = list[index]
    else
        enabled = not prev_enabled
    end

    vim.api.nvim_set_option_value(option, enabled, option_opts)

    if type(callback) == "function" then
        callback(enabled, prev_enabled)
    end

    if notify then
        local status
        if type(status) == "boolean" then
            status = M.bool2str(enabled)
        else
            status = enabled
        end
        vim.notify(string.format("%s: %s", option, status), vim.log.levels.INFO, { title = "Local Option" })
    end
end

---@class setting_opts
---@field callback? function
---@field notify? boolean

--- Toggle a buffer setting
---@param setting string
---@param opts? setting_opts
function M.toggle_buffer_setting(setting, opts)
    opts = opts or {}

    local callback = opts.callback
    local notify
    if opts.notify == nil then
        notify = true
    else
        notify = opts.notify
    end

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

    if type(callback) == "function" then
        callback(enabled, prev_enabled, global_enabled)
    end

    if notify then
        vim.notify(string.format("%s: %s", setting, M.bool2str(buffer_enabled)), vim.log.levels.INFO, { title = "Buffer" })
    end
end

--- Toggle a global setting
---@param setting string
---@param opts? setting_opts
function M.toggle_global_setting(setting, opts)
    opts = opts or {}

    local callback = opts.callback
    local notify
    if opts.notify == nil then
        notify = true
    else
        notify = opts.notify
    end

    local buf = vim.api.nvim_get_current_buf()
    local buffer_enabled = vim.b[buf][setting]
    local global_enabled = vim.g[setting] or false
    local prev_enabled
    if buffer_enabled == nil then
        prev_enabled = global_enabled
    else
        prev_enabled = buffer_enabled
    end

    global_enabled = not global_enabled
    vim.g[setting] = global_enabled
    local enabled
    if buffer_enabled == nil then
        enabled = global_enabled
    else
        enabled = buffer_enabled
    end

    if type(callback) == "function" then
        callback(enabled, prev_enabled, global_enabled)
    end

    if notify then
        vim.notify(string.format("%s: %s", setting, M.bool2str(global_enabled)), vim.log.levels.INFO, { title = "Global" })
    end
end

return M
