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
            vim.cmd("tabdo wincmd =")
        end,
        group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
    })



    -- 只在活动窗口显示 cursor line
    local cursor_line_only_in_active_window = vim.api.nvim_create_augroup("cursor_line_only_in_active_window", { clear = true })

    vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
        callback = function()
            local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
            if ok and cl then
                vim.opt.cursorline = true
                vim.api.nvim_win_del_var(0, "auto-cursorline")
            end
        end,
        group = cursor_line_only_in_active_window,
    })

    vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
        callback = function()
            local cl = vim.wo.cursorline
            if cl then
                vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
                vim.opt.cursorline = false
            end
        end,
        group = cursor_line_only_in_active_window,
    })



    -- Markdown 编辑
    local markdown = vim.api.nvim_create_augroup("markdown", { clear = true })

    -- 替换占位符
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".f", "<Esc>/<++><CR>:nohlsearch<CR>c4l", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。f", "<Esc>/<++><CR>:nohlsearch<CR>c4l", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 一级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".1", "#<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。1", "#<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 二级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".2", "##<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。2", "##<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 三级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".3", "###<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。3", "###<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 四级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".4", "####<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。4", "####<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 五级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".5", "#####<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。5", "#####<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 六级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".6", "######<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。6", "######<Enter><Enter><++><Esc>2kA<Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 粗体文本
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".b", "****<++><Esc>F*hi", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。b", "****<++><Esc>F*hi", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 斜体文本
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".i", "**<++><Esc>F*i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。i", "**<++><Esc>F*i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 粗斜体文本
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".e", "******<++><Esc>F*2hi", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。e", "******<++><Esc>F*2hi", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 下划线
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".s", "~~~~<++><Esc>F~hi", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。s", "~~~~<++><Esc>F~hi", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 引用
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".q", "><Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。q", "><Space>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 标注
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".c", "``<++><Esc>F`i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。c", "``<++><Esc>F`i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 插入代码块
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "..c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。。c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA``<++><Esc>F`i",
                { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 行内公式
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".m", "$$<++><Esc>F$i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。m", "$$<++><Esc>F$i``<++><Esc>F`i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 行间公式
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "..m", "$$<Enter><Enter>$$<Enter><Enter><++><Esc>3ki", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。。m", "$$<Enter><Enter>$$<Enter><Enter><++><Esc>3ki", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 插入分隔线
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".n", "---<Enter><Enter>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。n", "---<Enter><Enter>", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 插入图片
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".p", "![](<++>)<++><Esc>F[a", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。p", "![](<++>)<++><Esc>F[a", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 插入链接
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".l", "[](<++>)<++><Esc>F[a", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。l", "[](<++>)<++><Esc>F[a", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })

    -- 插入 html 的 center
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".hc", "<center><Enter><Enter><Enter><Enter></center><Enter><Enter><++><Esc>4ki",
                { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。hc", "<center><Enter><Enter><Enter><Enter></center><Enter><Enter><++><Esc>4ki",
                { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 插入 html 的 font color
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".hf", "<font color=></font><++><Esc>F=a", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。hf", "<font color=></font><++><Esc>F=a", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 插入 html 的 mark
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".hm", "<mark></mark><++><Esc>2F<i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。hm", "<mark></mark><++><Esc>2F<i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 插入 html 的 underline
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".hu", "<u></u><++><Esc>2F<i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。hu", "<u></u><++><Esc>2F<i", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })



    -- 使用宏时显示信息
    local recording = vim.api.nvim_create_augroup("recording", { clear = true })

    vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function()
            vim.api.nvim_command("set cmdheight=1")
        end,
        group = recording,
        pattern = "*",
    })

    vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
            vim.api.nvim_command("set cmdheight=0")
        end,
        group = recording,
        pattern = "*",
    })
end
