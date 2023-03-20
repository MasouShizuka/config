-- Modes
-- normal_mode       = "n",
-- insert_mode       = "i",
-- visual_mode       = "v",
-- visual_block_mode = "x",
-- term_mode         = "t",
-- command_mode      = "c",

local global = require("global")
local map = vim.api.nvim_set_keymap

-- 设置 leader 为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 不保存到寄存器
map("n", "C", '"_c', { noremap = true, silent = true })
map("v", "C", '"_c', { noremap = true, silent = true })
map("n", "D", '"_d', { noremap = true, silent = true })
map("v", "D", '"_d', { noremap = true, silent = true })

-- 选中上次粘贴的文本
map("n", "gp", "`[v`]", { noremap = true, silent = true })

-- 跳到行首行尾不带空格
map("n", "H", "^", { noremap = true, silent = true })
map("v", "H", "^", { noremap = true, silent = true })
map("o", "H", "^", { noremap = true, silent = true })
map("n", "L", "g_", { noremap = true, silent = true })
map("v", "L", "g_", { noremap = true, silent = true })
map("o", "L", "g_", { noremap = true, silent = true })

-- 折行时小步上下移动
map("n", "j", "v:count == 0 ? 'gjzz' : 'j'", { expr = true, silent = true })
map("v", "j", "v:count == 0 ? 'gjzz' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gkzz' : 'k'", { expr = true, silent = true })
map("v", "k", "v:count == 0 ? 'gkzz' : 'k'", { expr = true, silent = true })

-- 上下移动选中文本
map("v", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })
map("v", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })

-- 调整光标所在行到屏幕的位置
map("n", "zj", "zt", { silent = true })
map("n", "zk", "zb", { silent = true })

if global.is_vscode then
    vim.cmd [[
        " 插入新行
        nnoremap o i<Cmd>call VSCodeNotify("editor.action.insertLineAfter")<CR>
        nnoremap O i<Cmd>call VSCodeNotify("editor.action.insertLineBefore")<CR>

        " 注释
        xmap gc  <Plug>VSCodeCommentary
        nmap gc  <Plug>VSCodeCommentary
        omap gc  <Plug>VSCodeCommentary
        nmap gcc <Plug>VSCodeCommentaryLine

        " 块注释
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
        xnoremap <expr> gb <SID>Vscode_Block_Commentary()
        nnoremap <expr> gb <SID>Vscode_Block_Commentary()
        onoremap <expr> gb <SID>Vscode_Block_Commentary()
        nnoremap <expr> gbb <SID>Vscode_Block_Commentary() . '_'

        " 转到引用
        nnoremap ge <Cmd>call VSCodeNotify("editor.action.goToReferences")<CR>
        nnoremap gE <Cmd>call VSCodeNotify("editor.action.referenceSearch.trigger")<CR>

        " Debug 显示悬浮
        nnoremap gH <Cmd>call VSCodeNotify("editor.debug.action.showDebugHover")<CR>

        " 折叠
        nnoremap zc <Cmd>call VSCodeNotify("editor.fold")<CR>
        nnoremap zC <Cmd>call VSCodeNotify("editor.foldRecursively")<CR>
        nnoremap zo <Cmd>call VSCodeNotify("editor.unfold")<CR>
        nnoremap zO <Cmd>call VSCodeNotify("editor.unfoldRecursively")<CR>
        nnoremap za <Cmd>call VSCodeNotify("editor.toggleFold")<CR>
        nnoremap zm <Cmd>call VSCodeNotify("editor.foldAll")<CR>
        nnoremap zr <Cmd>call VSCodeNotify("editor.unfoldAll")<CR>

        " 格式化
        function! Vscode_Fomat()
            call VSCodeNotify("editor.action.formatDocument")
            call VSCodeNotify("notebook.formatCell")
        endfunction
        nnoremap <Leader>f <Cmd>call Vscode_Fomat()<CR>

        " 运行
        function! Run()
            if &filetype == "html" || &filetype == "xhtml"
                call VSCodeNotify("office.html.preview")
            elseif &filetype == "markdown"
                call VSCodeNotify("markdown.showPreviewToSide")
            elseif &filetype == "tex"
                call VSCodeNotify("latex-workshop.build")
            else
                call VSCodeNotify("code-runner.run")
            endif
        endfunction
        nnoremap <Leader>r <Cmd>call Run()<CR>

        " vscode 扩展
        nnoremap <Leader>b <Cmd>call VSCodeNotify("bookmarks.toggle")<CR>
        nnoremap <Leader>p <Cmd>call VSCodeNotify("extension.pasteImage")<CR>
    ]]
else
    -- 命令行上一个下一个
    map("c", "<Down>", "<C-n>", { noremap = true })
    map("c", "<Up>", "<C-p>", { noremap = true })
    map("c", "<C-j>", "<C-n>", { noremap = true })
    map("c", "<C-k>", "<C-p>", { noremap = true })

    -- 分屏
    map("n", "<C-j>", "<C-w>w", { noremap = true, silent = true })
    map("n", "<C-k>", "<C-w>W", { noremap = true, silent = true })
    map("n", "<C-s><C-j>", ":set splitbelow<CR><C-w>s", { noremap = true, silent = true })
    map("n", "<C-s><C-k>", ":set nosplitbelow<CR><C-w>s", { noremap = true, silent = true })
    map("n", "<C-s><C-l>", ":set splitright<CR><C-w>v", { noremap = true, silent = true })
    map("n", "<C-s><C-h>", ":set nosplitright<CR><C-w>v", { noremap = true, silent = true })
    map("n", "<C-Up>", "<C-w>+", { noremap = true, silent = true })
    map("n", "<C-Down>", "<C-w>-", { noremap = true, silent = true })
    map("n", "<C-Left>", "<C-w><", { noremap = true, silent = true })
    map("n", "<C-Right>", "<C-w>>", { noremap = true, silent = true })

    -- 保存和退出
    map("n", "<C-s>", "<Esc>:w<CR>", { noremap = true, silent = true })
    map("n", "<C-w>", "<Esc>:q!<CR>", { noremap = true, silent = true })

    vim.cmd [[
        " Markdown快捷输入

        " 替换操作
        autocmd Filetype markdown inoremap .f <Esc>/<++><CR>:nohlsearch<CR>c4l
        autocmd Filetype markdown inoremap 。f <Esc>/<++><CR>:nohlsearch<CR>c4l

        " 一级标题
        autocmd Filetype markdown inoremap .1 #<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap 。1 #<Space><Enter><Enter><++><Esc>2kA
        " 二级标题
        autocmd Filetype markdown inoremap .2 ##<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap 。2 ##<Space><Enter><Enter><++><Esc>2kA
        " 三级标题
        autocmd Filetype markdown inoremap .3 ###<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap 。3 ###<Space><Enter><Enter><++><Esc>2kA
        " 四级标题
        autocmd Filetype markdown inoremap .4 ####<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap 。4 ####<Space><Enter><Enter><++><Esc>2kA
        " 五级标题
        autocmd Filetype markdown inoremap .5 #####<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap 。5 #####<Space><Enter><Enter><++><Esc>2kA
        " 六级标题
        autocmd Filetype markdown inoremap .6 ######<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap 。6 ######<Space><Enter><Enter><++><Esc>2kA

        " 粗体文本
        autocmd Filetype markdown inoremap .b ****<++><Esc>F*hi
        autocmd Filetype markdown inoremap 。b ****<++><Esc>F*hi
        " 斜体文本
        autocmd Filetype markdown inoremap .i **<++><Esc>F*i
        autocmd Filetype markdown inoremap 。i **<++><Esc>F*i
        " 粗斜体文本
        autocmd Filetype markdown inoremap .e ******<++><Esc>F*hhi
        autocmd Filetype markdown inoremap 。e ******<++><Esc>F*hhi
        " 下划线
        autocmd Filetype markdown inoremap .s ~~~~<++><Esc>F~hi
        autocmd Filetype markdown inoremap 。s ~~~~<++><Esc>F~hi

        " 引用
        autocmd Filetype markdown inoremap .q ><Space>
        autocmd Filetype markdown inoremap 。q ><Space>

        " 标注
        autocmd Filetype markdown inoremap .c ``<++><Esc>F`i
        autocmd Filetype markdown inoremap 。c ``<++><Esc>F`i
        " 插入代码块
        autocmd Filetype markdown inoremap ..c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
        autocmd Filetype markdown inoremap 。。c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
        " 行内公式
        autocmd Filetype markdown inoremap .m $$<++><Esc>F$i
        autocmd Filetype markdown inoremap 。m $$<++><Esc>F$i
        " 行间公式
        autocmd Filetype markdown inoremap ..m $$<Enter><Enter>$$<Enter><Enter><++><Esc>3ki
        autocmd Filetype markdown inoremap 。。m $$<Enter><Enter>$$<Enter><Enter><++><Esc>3ki

        " 插入分隔线
        autocmd Filetype markdown inoremap .n ---<Enter><Enter>
        autocmd Filetype markdown inoremap 。n ---<Enter><Enter>

        " 插入图片
        autocmd Filetype markdown inoremap .p ![](<++>)<++><Esc>F[a
        autocmd Filetype markdown inoremap 。p ![](<++>)<++><Esc>F[a
        " 插入链接
        autocmd Filetype markdown inoremap .l [](<++>)<++><Esc>F[a
        autocmd Filetype markdown inoremap 。l [](<++>)<++><Esc>F[a

        " 插入 html 的 center
        autocmd Filetype markdown inoremap .hc <center><Enter><Enter><Enter><Enter></center><Enter><Enter><++><Esc>4ki
        autocmd Filetype markdown inoremap 。hc <center><Enter><Enter><Enter><Enter></center><Enter><Enter><++><Esc>4ki
        " 插入 html 的 font color
        autocmd Filetype markdown inoremap .hf <font color=></font><++><Esc>F=a
        autocmd Filetype markdown inoremap 。hf <font color=></font><++><Esc>F=a
        " 插入 html 的 mark
        autocmd Filetype markdown inoremap .hm <mark></mark><++><Esc>2F<i
        autocmd Filetype markdown inoremap 。hm <mark></mark><++><Esc>2F<i
        " 插入 html 的 underline
        autocmd Filetype markdown inoremap .hu <u></u><++><Esc>2F<i
        autocmd Filetype markdown inoremap 。hu <u></u><++><Esc>2F<i

        function! Run()
            execute "w"
            if &filetype == "c"
                execute "!g++ % -o %<"
                execute "!time ./%<"
            elseif &filetype == "cpp"
                set splitbelow
                execute "!g++ -std=c++11 % -Wall -o %<"
                :sp
                :res -15
                :term ./%<
            elseif &filetype == "cs"
                set splitbelow
                silent! execute "!mcs %"
                :sp
                :res -5
                :term mono %<.exe
            elseif &filetype == "java"
                set splitbelow
                :sp
                :res -5
                term javac % && time java %<
            elseif &filetype == "sh"
                :!time bash %
            elseif &filetype == "python"
                set splitbelow
                :sp
                :term python3 %
            elseif &filetype == "html"
                silent! execute "!".g:mkdp_browser." % &"
            elseif &filetype == "markdown"
                execute "MarkdownPreviewToggle"
            elseif &filetype == "tex"
                silent! execute "VimtexStop"
                silent! execute "VimtexCompile"
            elseif &filetype == "dart"
                execute "CocCommand flutter.run -d ".g:flutter_default_device." ".g:flutter_run_args
                silent! execute "CocCommand flutter.dev.openDevLog"
            elseif &filetype == "javascript"
                set splitbelow
                :sp
                :term export DEBUG="INFO,ERROR,WARNING"; node --trace-warnings .
            elseif &filetype == "go"
                set splitbelow
                :sp
                :term go run .
            endif
        endfunction
        noremap <Leader>r :call Run()<CR>
    ]]
end
