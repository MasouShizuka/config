-- Modes
-- normal_mode = "n",
-- insert_mode = "i",
-- visual_mode = "v",
-- visual_block_mode = "x",
-- term_mode = "t",
-- command_mode = "c",

-- 本地变量
local map = vim.api.nvim_set_keymap

local opt = {
    noremap = true,
    silent = true,
}

-- 设置 leader 为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "



-- 快捷键

-- 跳到行首行尾不带空格
map("n", "H", "^", opt)
map("v", "H", "^", opt)
map("o", "H", "^", opt)
map("n", "L", "g_", opt)
map("v", "L", "g_", opt)
map("o", "L", "g_", opt)

-- fix :set wrap
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- 上下移动选中文本
map("v", "J", ":move '>+1<CR>gv-gv", opt)
map("v", "K", ":move '<-2<CR>gv-gv", opt)

-- 在visual mode里粘贴不要复制
map("v", "p", '"_dP', opt)

-- magic search
map("n", "/", "/\\v", { noremap = true, silent = false })
map("v", "/", "/\\v", { noremap = true, silent = false })

if vim.g.vscode then
    vim.cmd [[
        nnoremap zc <Cmd>call VSCodeNotify("editor.fold")<CR>
        nnoremap zC <Cmd>call VSCodeNotify("editor.foldRecursively")<CR>
        nnoremap zo <Cmd>call VSCodeNotify("editor.unfold")<CR>
        nnoremap zO <Cmd>call VSCodeNotify("editor.unfoldRecursively")<CR>
        nnoremap za <Cmd>call VSCodeNotify("editor.toggleFold")<CR>
        nnoremap zm <Cmd>call VSCodeNotify("editor.foldAll")<CR>
        nnoremap zr <Cmd>call VSCodeNotify("editor.unfoldAll")<CR>

        nmap <C-d> :+9<CR>:+9<CR>:+2<CR>zz
        xmap <C-d> 9j9j
        nmap <C-u> :-9<CR>:-9<CR>:-2<CR>zz
        xmap <C-u> 9k9k

        xmap gc  <Plug>VSCodeCommentary
        nmap gc  <Plug>VSCodeCommentary
        omap gc  <Plug>VSCodeCommentary
        nmap gcc <Plug>VSCodeCommentaryLine

        nnoremap ge <Cmd>call VSCodeNotify("editor.action.goToReferences")<CR>

        nnoremap <Leader>b <Cmd>call VSCodeNotify("bookmarks.toggle")<CR>

        function! Compile_Run()
            if &filetype == "html" || &filetype == "xhtml"
                call VSCodeNotify("office.html.preview")
            elseif &filetype == "markdown"
                call VSCodeNotify("markdown-preview-enhanced.openPreviewToTheSide")
            else
                call VSCodeNotify("code-runner.run")
            endif
        endfunction
        nnoremap <Leader>r <Cmd>call Compile_Run()<CR>
    ]]
else
    -- 命令行下上一个下一个
    map("c", "<Down>", "<C-n>", { noremap = false })
    map("c", "<Up>", "<C-p>", { noremap = false })
    map("c", "<C-j>", "<C-n>", { noremap = false })
    map("c", "<C-k>", "<C-p>", { noremap = false })

    -- 居中
    map("n", "<C-d>", "<C-d>zz", { noremap = false })
    map("n", "<C-u>", "<C-u>zz", { noremap = false })

    -- 分屏
    map("n", "<C-j>", "<C-w>w", opt)
    map("n", "<C-k>", "<C-w>W", opt)
    map("n", "<C-s><C-j>", ":set splitbelow<CR><C-w>s", opt)
    map("n", "<C-s><C-k>", ":set nosplitbelow<CR><C-w>s", opt)
    map("n", "<C-s><C-l>", ":set splitright<CR><C-w>v", opt)
    map("n", "<C-s><C-h>", ":set nosplitright<CR><C-w>v", opt)
    map("n", "<C-Up>", "<C-w>+", opt)
    map("n", "<C-Down>", "<C-w>-", opt)
    map("n", "<C-Left>", "<C-w><", opt)
    map("n", "<C-Right>", "<C-w>>", opt)

    -- 保存和退出
    map("n", "<C-s>", "<Esc>:w<CR>", opt)
    map("n", "<C-w>", "<Esc>:q!<CR>", opt)

    vim.cmd [[
        " Markdown快捷输入

        " 替换操作
        autocmd Filetype markdown inoremap ,f <Esc>/<++><CR>:nohlsearch<CR>c4l
        autocmd Filetype markdown inoremap ，f <Esc>/<++><CR>:nohlsearch<CR>c4l
        " 一级标题
        autocmd Filetype markdown inoremap ,t1 #<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap ，t1 #<Space><Enter><Enter><++><Esc>2kA
        " 二级标题
        autocmd Filetype markdown inoremap ,t2 ##<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap ，t2 ##<Space><Enter><Enter><++><Esc>2kA
        " 三级标题
        autocmd Filetype markdown inoremap ,t3 ###<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap ，t3 ###<Space><Enter><Enter><++><Esc>2kA
        " 四级标题
        autocmd Filetype markdown inoremap ,t4 ####<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap ，t4 ####<Space><Enter><Enter><++><Esc>2kA
        " 五级标题
        autocmd Filetype markdown inoremap ,t5 #####<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap ，t5 #####<Space><Enter><Enter><++><Esc>2kA
        " 六级标题
        autocmd Filetype markdown inoremap ,t6 ######<Space><Enter><Enter><++><Esc>2kA
        autocmd Filetype markdown inoremap ，t6 ######<Space><Enter><Enter><++><Esc>2kA
        " 粗体文本
        autocmd Filetype markdown inoremap ,b ****<++><Esc>F*hi
        autocmd Filetype markdown inoremap ，b ****<++><Esc>F*hi
        " 斜体文本
        autocmd Filetype markdown inoremap ,i **<++><Esc>F*i
        autocmd Filetype markdown inoremap ，i **<++><Esc>F*i
        " 粗斜体文本
        autocmd Filetype markdown inoremap ,e ******<++><Esc>F*hhi
        autocmd Filetype markdown inoremap ，e ******<++><Esc>F*hhi
        " 高亮
        autocmd Filetype markdown inoremap ,h ====<++><Esc>F=hi
        autocmd Filetype markdown inoremap ，h ====<++><Esc>F=hi
        " 下划线
        autocmd Filetype markdown inoremap ,s ~~~~<++><Esc>F~hi
        autocmd Filetype markdown inoremap ，s ~~~~<++><Esc>F~hi
        " 引用
        autocmd Filetype markdown inoremap ,q > 
        autocmd Filetype markdown inoremap ，q > 
        " 标注
        autocmd Filetype markdown inoremap ,c ``<++><Esc>F`i
        autocmd Filetype markdown inoremap ，c ``<++><Esc>F`i
        " 插入代码块
        autocmd Filetype markdown inoremap ,,c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
        autocmd Filetype markdown inoremap ，,c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
        " 行内公式
        autocmd Filetype markdown inoremap ,m $$<++><Esc>F$i
        autocmd Filetype markdown inoremap ，m $$<++><Esc>F$i
        " 行间公式
        autocmd Filetype markdown inoremap ,,m $$<Enter><Enter>$$<Enter><Enter><++><Esc>3ki
        autocmd Filetype markdown inoremap ，,m $$<Enter><Enter>$$<Enter><Enter><++><Esc>3ki
        " 插入分隔线
        autocmd Filetype markdown inoremap ,n ---<Enter><Enter>
        autocmd Filetype markdown inoremap ，n ---<Enter><Enter>
        " 插入图片
        autocmd Filetype markdown inoremap ,p ![](<++>)<++><Esc>F[a
        autocmd Filetype markdown inoremap ，p ![](<++>)<++><Esc>F[a
        " 插入链接
        autocmd Filetype markdown inoremap ,l [](<++>)<++><Esc>F[a
        autocmd Filetype markdown inoremap ，l [](<++>)<++><Esc>F[a

        function! Compile_Run()
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
        noremap <Leader>r :call Compile_Run()<CR>
    ]]
end



-- 插件快捷键

-- clipboard-image.nvim
map("n", "<leader>p", ":PasteImg<CR>", opt)

-- hop.nvim
map('n', 's', "<cmd>lua require'hop'.hint_char1()<cr>", {})
map('v', 's', "<cmd>lua require'hop'.hint_char1()<cr>", {})

-- nvim-hlslens
map('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zz]], opt)
map('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zz]], opt)
map('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opt)
map('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opt)
map('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opt)
map('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opt)

-- vim-easy-align
map("n", "ga", "<Plug>(EasyAlign)", { noremap = false })
map("v", "ga", ":EasyAlign ", { noremap = false })

if not vim.g.vscode then
    -- bufferline.nvim
    map("n", "<C-h>", ":BufferLineCyclePrev<CR>", opt)
    map("n", "<C-l>", ":BufferLineCycleNext<CR>", opt)

    -- nvim-tree
    map('n', '<leader>n', ':NvimTreeToggle<CR>', opt)
end