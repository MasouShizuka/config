local variables = require("config.variables")

-- 设置 leader 为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 清除原有 keymap
vim.keymap.set({ "n", "x" }, "<space>", "<nop>", { silent = true })
vim.keymap.set({ "n", "x" }, "m", "<nop>", { silent = true })
vim.keymap.set({ "n", "x" }, "s", "<nop>", { silent = true })

-- 跳到行首行尾不带空格
vim.keymap.set({ "n", "x", "o" }, "H", "^", { desc = "Start of line (non-blank)", silent = true })
vim.keymap.set({ "n", "x", "o" }, "L", "g_", { desc = "End of line (non-blank)", silent = true })

-- 折行时小步上下移动
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 && mode() !=# 'V' ? 'gj' : 'j'", { desc = "Down", expr = true, remap = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 && mode() !=# 'V' ? 'gk' : 'k'", { desc = "Up", expr = true, remap = true, silent = true })

-- 上下移动选中文本
vim.keymap.set("x", "J", ":move '>+1<cr>gv-gv", { desc = "Move selected text up", silent = true })
vim.keymap.set("x", "K", ":move '<-2<cr>gv-gv", { desc = "Move selected text down", silent = true })

-- mark
vim.keymap.set("n", "M", "m", { desc = "Mark", silent = true })

-- 选中上次粘贴的文本
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select last pasted text", silent = true })

-- 调整光标所在行到屏幕的位置
vim.keymap.set({ "n", "x" }, "zj", "zt", { desc = "Top this line", remap = true, silent = true })
vim.keymap.set({ "n", "x" }, "zk", "zb", { desc = "Bottom this line", remap = true, silent = true })

if variables.is_vscode then
    -- 插入新行
    vim.keymap.set("n", "o", "i<cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>", { silent = true })
    vim.keymap.set("n", "O", "i<cmd>call VSCodeNotify('editor.action.insertLineBefore')<cr>", { silent = true })

    -- 注释
    vim.keymap.set({ "n", "x", "o" }, "gc", "<plug>VSCodeCommentary", { silent = true })
    vim.keymap.set("n", "gcc", "<plug>VSCodeCommentaryLine", { silent = true })
    vim.cmd([[
        function! s:Vscode_Block_Commentary(...) abort
            if !a:0
                let &operatorfunc = matchstr(expand("<sfile>"), "[^. ]*$")
                return "g@"
            elseif a:0 > 1
                let [line1, line2] = [a:1, a:2]
            else
                let [line1, line2] = [line("'["), line("']")]
            endif

            call VSCodeCallRange("editor.action.blockComment", line1, line2, 0)
        endfunction

        nnoremap <expr> <plug>VSCodeBlockCommentary <sid>Vscode_Block_Commentary()
        xnoremap <expr> <plug>VSCodeBlockCommentary <sid>Vscode_Block_Commentary()
        nnoremap <expr> <plug>VSCodeBlockCommentaryLine <sid>Vscode_Block_Commentary() . "_"
    ]])
    vim.keymap.set({ "n", "x", "o" }, "gb", "<plug>VSCodeBlockCommentary", { silent = true })
    vim.keymap.set("n", "gbb", "<plug>VSCodeBlockCommentaryLine", { silent = true })

    -- 转到
    vim.keymap.set("n", "gD", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.action.revealDeclaration" }) end, { silent = true })
    vim.keymap.set("n", "ge", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToReferences" }) end, { silent = true })
    vim.keymap.set("n", "gi", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToImplementation" }) end, { silent = true })
    vim.keymap.set("n", "gy", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.action.goToTypeDefinition" }) end, { silent = true })

    -- 折叠
    vim.keymap.set("n", "zc", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.fold" }) end, { silent = true })
    vim.keymap.set("n", "zC", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.foldRecursively" }) end, { silent = true })
    vim.keymap.set("n", "zo", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.unfold" }) end, { silent = true })
    vim.keymap.set("n", "zO", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.unfoldRecursively" }) end, { silent = true })
    vim.keymap.set("n", "za", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.toggleFold" }) end, { silent = true })
    vim.keymap.set("n", "zm", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.foldAll" }) end, { silent = true })
    vim.keymap.set("n", "zr", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.unfoldAll" }) end, { silent = true })

    -- 调试
    vim.keymap.set("n", "<leader>dr", function() vim.api.nvim_call_function("VSCodeNotify", { "workbench.action.debug.restart" }) end, { silent = true })
    vim.keymap.set("n", "<leader>dk", function() vim.api.nvim_call_function("VSCodeNotify", { "workbench.action.debug.callStackUp" }) end, { silent = true })
    vim.keymap.set("n", "<leader>dj", function() vim.api.nvim_call_function("VSCodeNotify", { "workbench.action.debug.callStackDown" }) end, { silent = true })
    vim.keymap.set("n", "<leader>dh", function() vim.api.nvim_call_function("VSCodeNotify", { "editor.debug.action.showDebugHover" }) end, { silent = true })

    -- 格式化
    vim.keymap.set("n", "<leader>f", function()
        vim.api.nvim_call_function("VSCodeNotify", { "editor.action.formatDocument" })
        vim.api.nvim_call_function("VSCodeNotify", { "notebook.formatCell" })
    end, { silent = true })

    -- 运行
    vim.keymap.set("n", "<leader>r", function()
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
    vim.keymap.set("n", "<leader>b", function() vim.api.nvim_call_function("VSCodeNotify", { "bookmarks.toggle" }) end, { silent = true })
    vim.keymap.set("n", "<leader>p", function() vim.api.nvim_call_function("VSCodeNotify", { "extension.pasteImage" }) end, { silent = true })
else
    -- 命令行
    vim.keymap.set("c", "<down>", "<c-n>", { desc = "Down", silent = true })
    vim.keymap.set("c", "<up>", "<c-p>", { desc = "Up", silent = true })
    vim.keymap.set("c", "<c-j>", "<c-n>", { desc = "Down", silent = true })
    vim.keymap.set("c", "<c-k>", "<c-p>", { desc = "Up", silent = true })

    -- 折行时小步上下移动
    vim.keymap.set("i", "<down>", "<c-o>gj", { desc = "Down", silent = true })
    vim.keymap.set("i", "<up>", "<c-o>gk", { desc = "Up", silent = true })

    -- 终端
    vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], { desc = "Enter normal mode", silent = true })

    -- 聚焦左侧边栏
    -- 由 edgy 设置
    -- vim.keymap.set("n", variables.keymap["<c-1>"], function()
    --     if not variables.toggle_filetype(variables.toggle_filetype_list1) then
    --         require("nvim-tree.api").tree.open()
    --     end
    -- end, { desc = "Focus left panel", silent = true })

    -- 聚焦编辑文件
    -- 由 edgy 设置
    -- vim.keymap.set("n", variables.keymap["<c-2>"], function()
    --     variables.skip_filetype(variables.skip_filetype_list1, "W")
    -- end, { desc = "Focus editor", silent = true })

    -- 聚焦底栏
    -- 由 edgy 设置
    -- vim.keymap.set("n", variables.keymap["<c-3>"], function()
    --     local count = vim.v.count
    --     if count > 0 then
    --         vim.api.nvim_command(tostring(count) .. "ToggleTerm")
    --         return
    --     end

    --     if not variables.toggle_filetype(variables.toggle_filetype_list2) then
    --         vim.api.nvim_command("ToggleTerm")
    --     end
    -- end, { desc = "Focus bottom panel", silent = true })

    -- 聚焦右侧边栏
    -- 由 edgy 设置
    -- vim.keymap.set("n", variables.keymap["<c-4>"], function()
    --     if not variables.toggle_filetype(variables.toggle_filetype_list3) then
    --         vim.api.nvim_command("DocsViewToggle")
    --     end
    -- end, { desc = "Focus right panel", silent = true })

    -- 搜索并替换
    -- 由 nvim-alt-substitute 设置
    -- vim.keymap.set("n", "<c-f>", ":%s///gI<left><left><left><left>", { desc = "Search and replace in file" })

    -- 窗口
    vim.keymap.set("n", "<c-e>", function() vim.cmd.wincmd("r") end, { desc = "Exchange window", silent = true })
    vim.keymap.set("n", "<c-j>", function()
        vim.cmd.wincmd("w")
        variables.skip_filetype(variables.skip_filetype_list2, "w")
    end, { desc = "Move to next window", silent = true })
    vim.keymap.set("n", "<c-k>", function()
        vim.cmd.wincmd("W")
        variables.skip_filetype(variables.skip_filetype_list2, "W")
    end, { desc = "Move to previous window", silent = true })
    vim.keymap.set("n", "<c-s>h", function()
        vim.api.nvim_set_option_value("splitright", false, {})
        vim.cmd.wincmd("v")
    end, { desc = "Split window to left", silent = true })
    vim.keymap.set("n", "<c-s>l", function()
        vim.api.nvim_set_option_value("splitright", true, {})
        vim.cmd.wincmd("v")
    end, { desc = "Split window to right", silent = true })
    vim.keymap.set("n", "<c-s>j", function()
        vim.api.nvim_set_option_value("splitbelow", true, {})
        vim.cmd.wincmd("s")
    end, { desc = "Split window to down", silent = true })
    vim.keymap.set("n", "<c-s>k", function()
        vim.api.nvim_set_option_value("splitbelow", false, {})
        vim.cmd.wincmd("s")
    end, { desc = "Split window to up", silent = true })
    -- 由 winshift 设置
    -- vim.keymap.set("n", "<c-s><c-h>", function() vim.cmd.wincmd("H") end, { desc = "Move window to left", silent = true })
    -- vim.keymap.set("n", "<c-s><c-l>", function() vim.cmd.wincmd("L") end, { desc = "Move window to right", silent = true })
    -- vim.keymap.set("n", "<c-s><c-j>", function() vim.cmd.wincmd("J") end, { desc = "Move window to down", silent = true })
    -- vim.keymap.set("n", "<c-s><c-k>", function() vim.cmd.wincmd("K") end, { desc = "Move window to up", silent = true })
    vim.keymap.set("n", "<c-left>", function() vim.cmd.wincmd("<") end, { desc = "Decrease window width", silent = true })
    vim.keymap.set("n", "<c-right>", function() vim.cmd.wincmd(">") end, { desc = "Increase window width", silent = true })
    vim.keymap.set("n", "<c-up>", function() vim.cmd.wincmd("+") end, { desc = "Increase window height", silent = true })
    vim.keymap.set("n", "<c-down>", function() vim.cmd.wincmd("-") end, { desc = "Decrease window height", silent = true })

    -- tab
    -- 由 bufferline 设置
    -- vim.keymap.set("n", "<c-h>", function() vim.cmd.tabnext() end, { desc = "Cycle next tab", silent = true })
    -- vim.keymap.set("n", "<c-l>", function() vim.cmd.tabprevious() end,, { desc = "Cycle previous tab", silent = true })
    vim.keymap.set("n", variables.keymap["<c-,>"], function() vim.cmd.tabmove("-") end, { desc = "Move tab left", silent = true })
    vim.keymap.set("n", variables.keymap["<c-.>"], function() vim.cmd.tabmove("+") end, { desc = "Move tab right", silent = true })
    vim.keymap.set("n", "<c-s>t", function() vim.api.nvim_command("tab sbuffer") end, { desc = "Copy tab", silent = true })
    vim.keymap.set("n", "<c-s>" .. variables.keymap["<c-,>"], function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.tabprevious()
        vim.api.nvim_command("vertical sbuffer " .. buf)
    end, { desc = "Split buffer to previous tab", silent = true })
    vim.keymap.set("n", "<c-s>" .. variables.keymap["<c-.>"], function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.tabnext()
        vim.api.nvim_command("vertical sbuffer " .. buf)
    end, { desc = "Split buffer to next tab", silent = true })

    -- 跳转居中
    vim.keymap.set("n", "<c-i>", "<c-i>zz", { desc = "Jump to next location", silent = true })
    vim.keymap.set("n", "<c-o>", "<c-o>zz", { desc = "Jump to previous location", silent = true })

    -- diff
    vim.keymap.set("n", "<c-n>", function()
        vim.cmd.normal("]c")
        vim.cmd.normal("zz")
    end, { desc = "Next diff", silent = true })
    vim.keymap.set("n", variables.keymap["<c-s-n>"], function()
        vim.cmd.normal("[c")
        vim.cmd.normal("zz")
    end, { desc = "Previous diff", silent = true })

    -- 退出
    vim.keymap.set({ "n", "x" }, "<c-w>", "<cmd>q!<cr><esc>", { desc = "Quit", silent = true })
    vim.keymap.set({ "n", "x" }, "<leader><c-w>", "<cmd>qa!<cr><esc>", { desc = "Quit all", silent = true })

    -- 运行
    vim.keymap.set("n", "<leader>r", function()
        local path = vim.fn.expand("%:~:.")
        if variables.is_windows then
            path = path:gsub("\\", "/")
        end

        local ok, _ = pcall(require, "toggleterm")
        local filetype = vim.bo.filetype
        if ok then
            if variables.is_windows then
                vim.opt.shellslash = true
            end
            if filetype == "lua" then
                vim.api.nvim_command(([[TermExec cmd='lua "%s"']]):format(path))
            elseif filetype == "markdown" then
                vim.api.nvim_command("MarkdownPreviewToggle")
            elseif filetype == "python" then
                vim.api.nvim_command(([[TermExec cmd='python -u "%s"']]):format(path))
            elseif filetype == "rust" then
                vim.api.nvim_command([[TermExec cmd='cargo run']])
            elseif filetype == "sh" then
                vim.api.nvim_command(([[TermExec cmd='bash "%s"']]):format(path))
            end
            if variables.is_windows then
                vim.opt.shellslash = false
            end
        else
            if filetype == "lua" then
                vim.api.nvim_command("luafile %")
            elseif filetype == "markdown" then
                vim.api.nvim_command("MarkdownPreviewToggle")
            elseif filetype == "python" then
                vim.api.nvim_command("python -u %")
            elseif filetype == "rust" then
                vim.api.nvim_command("cargo run")
            elseif filetype == "sh" then
                vim.api.nvim_command("bash %")
            end
        end
    end, { desc = "Run", silent = true })
end
