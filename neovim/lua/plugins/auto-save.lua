local variables = require("variables")

return {
    "https://git.sr.ht/~nedia/auto-save.nvim",
    cond = not variables.is_vscode,
    event = { "InsertLeave", "TextChanged" },
    opts = {
        -- The name of the augroup.
        augroup_name = "AutoSavePlug",
        -- The events in which to trigger an auto save.
        -- events = { "InsertLeave", "TextChanged" },
        events = { "BufLeave", "FocusLost", "InsertLeave", "TextChanged" },
        -- If you'd prefer to silence the output of `save_fn`.
        silent = true,
        -- If you'd prefer to write a vim command.
        save_cmd = nil,
        -- What to do after checking if auto save conditions have been met.
        save_fn = function()
            -- 保存文件前保存上次复制的范围
            local last_paste_start = vim.fn.getpos("'[")
            local last_paste_end = vim.fn.getpos("']")

            local config = require("auto-save.config")
            if config.save_cmd ~= nil then
                vim.api.nvim_command(config.save_cmd)
            elseif config.silent then
                vim.api.nvim_command("silent! w")
            else
                vim.api.nvim_command("w")
            end

            -- 读取上次复制的范围
            vim.fn.setpos("'[", last_paste_start)
            vim.fn.setpos("']", last_paste_end)
        end,
        -- May define a timeout, or a duration to defer the save for - this allows
        -- for formatters to run, for example if they're configured via an autocmd
        -- that listens for `BufWritePre` event.
        -- 设置 timeout 确保能产生 BufWrite Event
        timeout = 1,
        -- Define some filetypes to explicitly not save, in case our existing conditions
        -- don't quite catch all the buffers we'd prefer not to write to.
        exclude_ft = {},
    },
}
