local M = {}

local prev_tabpage_count = vim.fn.tabpagenr("$")
local prev_tabpage = vim.fn.tabpagenr()

M.setup = function(opts)
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local tabpage_count = vim.fn.tabpagenr("$")
            local tabpage = vim.fn.tabpagenr()
            if tabpage > 1 and prev_tabpage ~= prev_tabpage_count and tabpage_count < prev_tabpage_count then
                vim.cmd.tabprevious()
            end
            prev_tabpage_count = tabpage_count
            prev_tabpage = vim.fn.tabpagenr()
        end,
        desc = "Go to left tab after closing tab",
        group = vim.api.nvim_create_augroup("GoToLeftTab", { clear = true }),
    })
end

return M
