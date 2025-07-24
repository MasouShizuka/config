-- hlsearch.nvim
-- https://github.com/nvimdev/hlsearch.nvim

local M = {}

local default_config = {
    delay = 0,
    pre_hook = function() end,
    post_hook = function() end,
}
local config = vim.fn.deepcopy(default_config)

local function stop_hl()
    if vim.v.hlsearch == 0 then
        return
    end

    local keycode = vim.api.nvim_replace_termcodes("<cmd>nohl<cr>", true, false, true)
    vim.api.nvim_feedkeys(keycode, "n", false)

    config.post_hook()
end

local function start_hl()
    if vim.v.hlsearch ~= 1 then
        return
    end

    config.pre_hook()

    local reg = vim.fn.getreg("/")
    if reg:find([[%#]], 1, true) then
        stop_hl()
        return
    end

    require("utils").defer_fn(function()
        local ok, res = pcall(vim.fn.search, [[\%#\zs]] .. reg, "cnW")
        if ok and res == 0 then
            stop_hl()
            return
        end
    end, {
        timeout = config.delay,
        use_timer = true,
    })
end

local group = vim.api.nvim_create_augroup("Hlsearch", { clear = true })

local function hs_event()
    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = start_hl,
        desc = "Auto hlsearch",
        group = group,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = stop_hl,
        desc = "Auto remove hlsearch",
        group = group,
    })
end

M.setup = function(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    hs_event()
end

return M
