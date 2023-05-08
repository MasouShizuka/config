local variables = require("variables")

if not variables.is_vscode then
    -- Auto create dir when saving a file, in case some intermediate directory does not exist
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        callback = function(event)
            local file = vim.loop.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end,
        group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
    })

    -- Check if we need to reload the file when it changed
    vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        command = "checktime",
        group = vim.api.nvim_create_augroup("checktime", { clear = true }),
    })

    -- go to last loc when opening a buffer
    vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end,
        group = vim.api.nvim_create_augroup("last_loc", { clear = true }),
    })

    -- resize splits if window got resized
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        callback = function()
            vim.api.nvim_command("tabdo wincmd =")
        end,
        group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
    })

    -- 使用宏时显示信息
    local recording = vim.api.nvim_create_augroup("recording", { clear = true })
    vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function()
            vim.api.nvim_set_option("cmdheight", 1)
        end,
        group = recording,
        pattern = "*",
    })
    vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
            vim.api.nvim_set_option("cmdheight", 0)
        end,
        group = recording,
        pattern = "*",
    })
end
