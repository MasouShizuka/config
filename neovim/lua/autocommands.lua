local variables = require("variables")

if not variables.is_vscode then
    local markdown = vim.api.nvim_create_augroup("markdown", {
        clear = true,
    })

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
            vim.keymap.set("i", ".1", "#<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。1", "#<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 二级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".2", "##<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。2", "##<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 三级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".3", "###<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。3", "###<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 四级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".4", "####<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。4", "####<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 五级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".5", "#####<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。5", "#####<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    -- 六级标题
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", ".6", "######<Space><Enter><Enter><++><Esc>2kA", { silent = true })
        end,
        group = markdown,
        pattern = "markdown",
    })
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            vim.keymap.set("i", "。6", "######<Space><Enter><Enter><++><Esc>2kA", { silent = true })
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
end
