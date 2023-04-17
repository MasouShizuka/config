local variables = require("variables")

-- 设置 leader 为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- 选中上次粘贴的文本
vim.keymap.set("n", "gp", "`[v`]", { silent = true })

-- 跳到行首行尾不带空格
vim.keymap.set({ "n", "x", "o" }, "H", "^", { silent = true })
vim.keymap.set({ "n", "x", "o" }, "L", "g_", { silent = true })

-- 折行时小步上下移动
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, remap = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, remap = true, silent = true })

-- 上下移动选中文本
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { silent = true })
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { silent = true })

-- 调整光标所在行到屏幕的位置
vim.keymap.set("n", "zj", "zt", { remap = true, silent = true })
vim.keymap.set("n", "zk", "zb", { remap = true, silent = true })

if variables.is_vscode then
    -- 插入新行
    vim.keymap.set("n", "o", "i<Cmd>call VSCodeNotify('editor.action.insertLineAfter')<CR>", { silent = true })
    vim.keymap.set("n", "O", "i<Cmd>call VSCodeNotify('editor.action.insertLineBefore')<CR>", { silent = true })

    -- 注释
    vim.keymap.set({ "n", "x", "o" }, "gc", "<Plug>VSCodeCommentary", { silent = true })
    vim.keymap.set("n", "gcc", "<Plug>VSCodeCommentaryLine", { silent = true })
    -- 块注释
    vim.cmd [[
        function! s:Vscode_Block_Commentary(...) abort
            if !a:0
                let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
                return 'g@'
            elseif a:0 > 1
                let [line1, line2] = [a:1, a:2]
            else
                let [line1, line2] = [line("'["), line("']")]
            endif

            call VSCodeCallRange('editor.action.blockComment', line1, line2, 0)
        endfunction

        nnoremap <expr> <Plug>VSCodeBlockCommentary <SID>Vscode_Block_Commentary()
        xnoremap <expr> <Plug>VSCodeBlockCommentary <SID>Vscode_Block_Commentary()
        nnoremap <expr> <Plug>VSCodeBlockCommentaryLine <SID>Vscode_Block_Commentary() . '_'
    ]]
    vim.keymap.set({ "n", "x", "o" }, "gb", "<Plug>VSCodeBlockCommentary", { silent = true })
    vim.keymap.set("n", "gbb", "<Plug>VSCodeBlockCommentaryLine", { silent = true })

    -- 转到引用
    vim.keymap.set("n", "ge", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToReferences" })
    end, { silent = true })
    vim.keymap.set("n", "gE", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.referenceSearch.trigger" })
    end, { silent = true })

    -- Debug 显示悬浮
    vim.keymap.set("n", "gH", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.debug.action.showDebugHover" })
    end, { silent = true })

    -- 折叠
    vim.keymap.set("n", "zc", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.fold" })
    end, { silent = true })
    vim.keymap.set("n", "zC", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.foldRecursively" })
    end, { silent = true })
    vim.keymap.set("n", "zo", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.unfold" })
    end, { silent = true })
    vim.keymap.set("n", "zO", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.unfoldRecursively" })
    end, { silent = true })
    vim.keymap.set("n", "za", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.toggleFold" })
    end, { silent = true })
    vim.keymap.set("n", "zm", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.foldAll" })
    end, { silent = true })
    vim.keymap.set("n", "zr", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.unfoldAll" })
    end, { silent = true })

    -- 格式化
    vim.keymap.set("n", "<Leader>f", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.formatDocument" })
        vim.api.nvim_call_function("VSCodeNotify", { "notebook.formatCell" })
    end, { silent = true })

    -- 运行
    vim.keymap.set("n", "<Leader>r", function()
        local filetype = vim.bo.filetype

        if filetype == "html" or filetype == "xhtml" then
            vim.api.nvim_call_function("VSCodeNotify", { "office.html.preview" })
        elseif filetype == "markdown" then
            vim.api.nvim_call_function("VSCodeNotify", { "markdown.showPreviewToSide" })
        elseif filetype == "tex" then
            vim.api.nvim_call_function("VSCodeNotify", { "latex-workshop.build" })
        else
            vim.api.nvim_call_function("VSCodeNotify", { "code-runner.run" })
        end
    end, { silent = true })

    -- vscode 扩展
    vim.keymap.set("n", "<Leader>b", function()
        vim.api.nvim_call_function("VSCodeNotify", { "bookmarks.toggle" })
    end, { silent = true })
    vim.keymap.set("n", "<Leader>p", function()
        vim.api.nvim_call_function("VSCodeNotify", { "extension.pasteImage" })
    end, { silent = true })
else
    -- 命令行上一个下一个
    vim.keymap.set("c", "<Down>", "<C-n>")
    vim.keymap.set("c", "<Up>", "<C-p>")
    vim.keymap.set("c", "<C-j>", "<C-n>")
    vim.keymap.set("c", "<C-k>", "<C-p>")

    -- 分屏
    vim.keymap.set("n", "<C-j>", "<C-w>w", { silent = true })
    vim.keymap.set("n", "<C-k>", "<C-w>W", { silent = true })
    vim.keymap.set("n", "<C-s>h", ":set nosplitright<CR><C-w>v", { silent = true })
    vim.keymap.set("n", "<C-s>l", ":set splitright<CR><C-w>v", { silent = true })
    vim.keymap.set("n", "<C-s>j", ":set splitbelow<CR><C-w>s", { silent = true })
    vim.keymap.set("n", "<C-s>k", ":set nosplitbelow<CR><C-w>s", { silent = true })
    vim.keymap.set("n", "<C-s><C-h>", "<C-w>H", { silent = true })
    vim.keymap.set("n", "<C-s><C-l>", "<C-w>L", { silent = true })
    vim.keymap.set("n", "<C-s><C-j>", "<C-w>J", { silent = true })
    vim.keymap.set("n", "<C-s><C-k>", "<C-w>K", { silent = true })
    vim.keymap.set("n", "<C-Up>", "<C-w>+", { silent = true })
    vim.keymap.set("n", "<C-Down>", "<C-w>-", { silent = true })
    vim.keymap.set("n", "<C-Left>", "<C-w><", { silent = true })
    vim.keymap.set("n", "<C-Right>", "<C-w>>", { silent = true })

    -- 保存和退出
    vim.keymap.set("n", "<C-s>", "<Esc>:w<CR>", { silent = true })
    vim.keymap.set("n", "<C-w>", "<Esc>:q!<CR>", { silent = true })

    -- 运行
    vim.keymap.set("n", "<Leader>r", function()
        local filetype = vim.bo.filetype

        if filetype == "markdown" then
            vim.api.nvim_command("MarkdownPreviewToggle")
        elseif filetype == "sh" then
            vim.api.nvim_command("!time bash %")
        end
    end, { silent = true })

    -- 打开终端
    vim.keymap.set("n", "<leader>t", function() require("lazy.util").float_term() end, { desc = "Terminal (cwd)" })
end
