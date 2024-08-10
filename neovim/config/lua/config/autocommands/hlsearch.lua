-- hlsearch.nvim
-- https://github.com/nvimdev/hlsearch.nvim

local M = {}

local config = {
    pre_hook = function() end,
    post_hook = function() end,
}

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

    local res = vim.fn.getreg("/")
    if res:find([[%#]], 1, true) then
        stop_hl()
        return
    end
    ok, res = pcall(vim.fn.search, [[\%#\zs]] .. res, "cnW")
    if ok and res == 0 then
        stop_hl()
        return
    end
end

local group = vim.api.nvim_create_augroup("Hlsearch", { clear = true })

local function hs_event()
    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            start_hl()
        end,
        desc = "Auto hlsearch",
        group = group,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            stop_hl()
        end,
        desc = "Auto remove hlsearch",
        group = group,
    })
end

M.setup = function(opts)
    opts = opts or {}
    config = vim.tbl_deep_extend("force", config, opts)

    hs_event()
end

return M
