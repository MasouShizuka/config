local variables = require("variables")

-- 设置 leader 为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 清除原有 keymap
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "x" }, "m", "<Nop>", { silent = true })
vim.keymap.set({ "n", "x" }, "s", "<Nop>", { silent = true })

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

-- Mark
vim.keymap.set("n", "M", "m", { silent = true })

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
    vim.cmd([[
        function! s:Vscode_Block_Commentary(...) abort
            if !a:0
                let &operatorfunc = matchstr(expand("<sfile>"), "[^. ]*$")
                return 'g@'
            elseif a:0 > 1
                let [line1, line2] = [a:1, a:2]
            else
                let [line1, line2] = [line("'["), line("']")]
            endif

            call VSCodeCallRange("editor.action.blockComment", line1, line2, 0)
        endfunction

        nnoremap <expr> <Plug>VSCodeBlockCommentary <SID>Vscode_Block_Commentary()
        xnoremap <expr> <Plug>VSCodeBlockCommentary <SID>Vscode_Block_Commentary()
        nnoremap <expr> <Plug>VSCodeBlockCommentaryLine <SID>Vscode_Block_Commentary() . "_"
    ]])
    vim.keymap.set({ "n", "x", "o" }, "gb", "<Plug>VSCodeBlockCommentary", { silent = true })
    vim.keymap.set("n", "gbb", "<Plug>VSCodeBlockCommentaryLine", { silent = true })

    -- 转到
    vim.keymap.set("n", "gD", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.revealDeclaration" })
    end, { silent = true })
    vim.keymap.set("n", "ge", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToReferences" })
    end, { silent = true })
    vim.keymap.set("n", "gi", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToImplementation" })
    end, { silent = true })
    vim.keymap.set("n", "gy", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToTypeDefinition" })
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

    -- Debug
    vim.keymap.set("n", "<Leader>dr", function()
        vim.api.nvim_call_function("VSCodeNotify", { "workbench.action.debug.restart" })
    end, { silent = true })
    vim.keymap.set("n", "<Leader>dk", function()
        vim.api.nvim_call_function("VSCodeNotify", { "workbench.action.debug.callStackUp" })
    end, { silent = true })
    vim.keymap.set("n", "<Leader>dj", function()
        vim.api.nvim_call_function("VSCodeNotify", { "workbench.action.debug.callStackDown" })
    end, { silent = true })
    vim.keymap.set("n", "<Leader>dh", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.debug.action.showDebugHover" })
    end, { silent = true })

    -- Format
    vim.keymap.set("n", "<Leader>f", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.formatDocument" })
        vim.api.nvim_call_function("VSCodeNotify", { "notebook.formatCell" })
    end, { silent = true })

    -- Run
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

    -- 聚焦编辑文件
    vim.keymap.set("n", variables.alacritty_keymap["<C-2>"], function()
        variables.skip_filetype(variables.skip_filetype_list1, "W")
    end, { silent = true })

    -- Tab
    -- vim.keymap.set("n", "<C-h>", "gt", { silent = true })
    -- vim.keymap.set("n", "<C-l>", "gT", { silent = true })
    vim.keymap.set("n", variables.alacritty_keymap["<C-,>"], function()
        vim.cmd.tabmove("-")
    end, { silent = true })
    vim.keymap.set("n", variables.alacritty_keymap["<C-.>"], function()
        vim.cmd.tabmove("+")
    end, { silent = true })

    -- 窗口间移动焦点
    vim.keymap.set("n", "<C-j>", function()
        vim.cmd.wincmd("w")
        variables.skip_filetype(variables.skip_filetype_list2, "w")
    end, { silent = true })
    vim.keymap.set("n", "<C-k>", function()
        vim.cmd.wincmd("W")
        variables.skip_filetype(variables.skip_filetype_list2, "W")
    end, { silent = true })

    -- 分屏
    vim.keymap.set("n", "<C-s>h", function()
        vim.api.nvim_set_option("splitright", false)
        vim.cmd.wincmd("v")
    end, { silent = true })
    vim.keymap.set("n", "<C-s>l", function()
        vim.api.nvim_set_option("splitright", true)
        vim.cmd.wincmd("v")
    end, { silent = true })
    vim.keymap.set("n", "<C-s>j", function()
        vim.api.nvim_set_option("splitbelow", true)
        vim.cmd.wincmd("s")
    end, { silent = true })
    vim.keymap.set("n", "<C-s>k", function()
        vim.api.nvim_set_option("splitbelow", false)
        vim.cmd.wincmd("s")
    end, { silent = true })
    vim.keymap.set("n", "<C-s><C-h>", function()
        vim.cmd.wincmd("H")
    end, { silent = true })
    vim.keymap.set("n", "<C-s><C-l>", function()
        vim.cmd.wincmd("L")
    end, { silent = true })
    vim.keymap.set("n", "<C-s><C-j>", function()
        vim.cmd.wincmd("J")
    end, { silent = true })
    vim.keymap.set("n", "<C-s><C-k>", function()
        vim.cmd.wincmd("K")
    end, { silent = true })
    vim.keymap.set("n", "<C-Up>", function()
        vim.cmd.wincmd("+")
    end, { silent = true })
    vim.keymap.set("n", "<C-Down>", function()
        vim.cmd.wincmd("-")
    end, { silent = true })
    vim.keymap.set("n", "<C-Left>", function()
        vim.cmd.wincmd("<")
    end, { silent = true })
    vim.keymap.set("n", "<C-Right>", function()
        vim.cmd.wincmd(">")
    end, { silent = true })

    -- 保存和退出
    vim.keymap.set({ "n", "x", "i" }, "<C-s>", "<Cmd>w<CR><ESC>", { silent = true })
    vim.keymap.set({ "n", "x" }, "<C-w>", "<Cmd>q!<CR><ESC>", { silent = true })
    vim.keymap.set({ "n", "x" }, "<Leader><C-w>", "<Cmd>qa!<CR><ESC>", { silent = true })

    -- 运行
    vim.keymap.set("n", "<Leader>r", function()
        local filetype = vim.bo.filetype

        if filetype == "lua" then
            -- vim.api.nvim_command("lua %")
            vim.api.nvim_command([[TermExec cmd="lua %"]])
        elseif filetype == "markdown" then
            vim.api.nvim_command("MarkdownPreviewToggle")
        elseif filetype == "python" then
            -- vim.api.nvim_command("python -u %")
            vim.api.nvim_command([[TermExec cmd="python -u %"]])
        elseif filetype == "rust" then
            -- vim.api.nvim_command("cargo run")
            vim.api.nvim_command([[TermExec cmd="cargo run"]])
        elseif filetype == "sh" then
            -- vim.api.nvim_command("bash %")
            vim.api.nvim_command([[TermExec cmd="bash %"]])
        end
    end, { silent = true })

    -- 终端
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true })
end
