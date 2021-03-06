"  判断 OS 函数
silent function! WINDOWS()
    return has('win64') || has('win32') || has('win16')
endfunction
silent function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! WSL()
    return has('wsl')
endfunction
silent function! OSX()
    return has('macunix')
endfunction



let mapleader = ' '
let &t_ut=''



" ##########
" # plugin #
" ##########

"  插件目录
let g:plugin_path = ''
if WINDOWS()
    let g:plugin_path = 'D:/Tools/Neovim/plugged'
elseif LINUX()
    let g:plugin_path = '~/.config/nvim/plugged'
endif

call plug#begin(g:plugin_path)

Plug 'junegunn/vim-easy-align'
nmap ga <Plug>(EasyAlign)
xmap ga :EasyAlign 

Plug 'machakann/vim-highlightedyank'
highlight HighlightedyankRegion cterm=reverse gui=reverse

Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/ReplaceWithRegister'

if WINDOWS()
    Plug 'brglng/vim-im-select'
    let g:im_select_command = 'C:/Users/MasouShizuka/AppData/Local/nvim/im-select.exe'
    let g:im_select_default = '1033'
" elseif WSL()
"     Plug 'brglng/vim-im-select'
"     let g:im_select_command = '/mnt/c/Users/MasouShizuka/AppData/Local/nvim/im-select.exe'
"     let g:im_select_default = '1033'
endif

if exists('g:vscode')
    Plug 'asvetliakov/vim-easymotion-vscode'
else
    Plug 'easymotion/vim-easymotion'

    Plug 'ferrine/md-img-paste.vim'
    autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
    let g:mdip_imgdir = '_images'
    let g:mdip_imgname = ''

    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    let g:VM_default_mappings = 0

    Plug 'olimorris/onedarkpro.nvim'

    Plug 'preservim/nerdtree'
    map <Leader>n :NERDTreeToggle<CR>
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
    autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
    let NERDTreeShowHidden=1
    let NERDTreeShowLineNumbers=1
    let NERDTreeMapJumpNextSibling='<C-d>'
    let NERDTreeMapJumpPrevSibling='<C-u>'

    Plug 'ryanoasis/vim-devicons'
    Plug 'tpope/vim-commentary'

    Plug 'vim-airline/vim-airline'
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_section_z = '%p%% %l/%L,%v %{strftime("%Y-%m-%d %H:%M")}'
endif

call plug#end()



" #######
" # set #
" #######

set autochdir
set autoread
set clipboard+=unnamedplus
set wildmenu

set autoindent
set smartindent

set cursorline
set list
set listchars=tab:▸\ ,trail:▫
set number
set relativenumber
set scrolloff=5
set showcmd
set showmatch
set syntax=on

set encoding=utf-8
set fileencodings=utf-8,gb2312,gbk,cp936,latin-1
set fileencoding=utf-8
set termencoding=utf-8

set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

set hlsearch
set incsearch
set ignorecase
set smartcase

set shada="NONE"

if WINDOWS()
    set fileformat=dos
elseif LINUX()
    set fileformat=unix
endif



" ###############
" # colorscheme #
" ###############

if !exists('g:vscode')
    colorscheme onedarkpro
endif



" ############
" # filetype #
" ############

filetype on
filetype indent on
filetype plugin on
filetype plugin indent on



" #######
" # map #
" #######

nnoremap H ^
xnoremap H ^
onoremap H ^
nnoremap L $
xnoremap L $
onoremap L $

nmap n nzz
nmap N Nzz

nmap s <leader><leader>s
xmap s <leader><leader>s

if exists('g:vscode')
    nnoremap o A<CR>

    nnoremap zc <Cmd>call VSCodeNotify('editor.fold')<CR>
    nnoremap zC <Cmd>call VSCodeNotify('editor.foldRecursively')<CR>
    nnoremap zo <Cmd>call VSCodeNotify('editor.unfold')<CR>
    nnoremap zO <Cmd>call VSCodeNotify('editor.unfoldRecursively')<CR>
    nnoremap za <Cmd>call VSCodeNotify('editor.toggleFold')<CR>
    nnoremap zm <Cmd>call VSCodeNotify('editor.foldAll')<CR>
    nnoremap zr <Cmd>call VSCodeNotify('editor.unfoldAll')<CR>

    nmap <C-d> :+9<CR>:+9<CR>:+2<CR>zz
    xmap <C-d> 9j9j
    nmap <C-u> :-9<CR>:-9<CR>:-2<CR>zz
    xmap <C-u> 9k9k

    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine

    nnoremap ge <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

    nnoremap <Leader>b <Cmd>call VSCodeNotify('bookmarks.toggle')<CR>
    nnoremap <Leader>p <Cmd>call VSCodeNotify('extension.pasteImage')<CR>

    function! Compile_Run()
        if &filetype == 'html' || &filetype == 'xhtml'
            call VSCodeNotify('office.html.preview')
        elseif &filetype == 'markdown'
            call VSCodeNotify('markdown-preview-enhanced.openPreviewToTheSide')
        else
            call VSCodeNotify('code-runner.run')
        endif
    endfunction
    nnoremap <Leader>r <Cmd>call Compile_Run()<CR>
else
    inoremap ' ''<Esc>i
    inoremap " ""<Esc>i
    inoremap ( ()<Esc>i
    inoremap [ []<Esc>i
    inoremap { {}<Esc>i

    inoremap <C-j> <Left>
    inoremap <C-l> <Right>
    inoremap <C-k> <Down>
    inoremap <C-i> <Up>

    nnoremap <C-d> <C-d>zz
    xnoremap <C-d> <C-d>zz
    nnoremap <C-u> <C-u>zz
    xnoremap <C-u> <C-u>zz

    nnoremap <C-h> gT
    nnoremap <C-l> gt

    nnoremap <C-j> <C-w>w
    nnoremap <C-k> <C-w>W

    map <C-s> <Esc>:w<CR>
    map <C-w> <Esc>:q!<CR>

    noremap <C-s><C-j> :set splitbelow<CR><C-w>s
    noremap <C-s><C-k> :set nosplitbelow<CR><C-w>s
    noremap <C-s><C-l> :set splitright<CR><C-w>v
    noremap <C-s><C-h> :set nosplitright<CR><C-w>v

    noremap <C-Up> <C-w>+
    noremap <C-Down> <C-w>-
    noremap <C-Left> <C-w><
    noremap <C-Right> <C-w>>

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
        execute 'w'
        if &filetype == 'c'
            execute '!g++ % -o %<'
            execute '!time ./%<'
        elseif &filetype == 'cpp'
            set splitbelow
            execute '!g++ -std=c++11 % -Wall -o %<'
            :sp
            :res -15
            :term ./%<
        elseif &filetype == 'cs'
            set splitbelow
            silent! execute '!mcs %'
            :sp
            :res -5
            :term mono %<.exe
        elseif &filetype == 'java'
            set splitbelow
            :sp
            :res -5
            term javac % && time java %<
        elseif &filetype == 'sh'
            :!time bash %
        elseif &filetype == 'python'
            set splitbelow
            :sp
            :term python3 %
        elseif &filetype == 'html'
            silent! execute '!'.g:mkdp_browser.' % &'
        elseif &filetype == 'markdown'
            execute 'MarkdownPreviewToggle'
        elseif &filetype == 'tex'
            silent! execute 'VimtexStop'
            silent! execute 'VimtexCompile'
        elseif &filetype == 'dart'
            execute 'CocCommand flutter.run -d '.g:flutter_default_device.' '.g:flutter_run_args
            silent! execute 'CocCommand flutter.dev.openDevLog'
        elseif &filetype == 'javascript'
            set splitbelow
            :sp
            :term export DEBUG='INFO,ERROR,WARNING'; node --trace-warnings .
        elseif &filetype == 'go'
            set splitbelow
            :sp
            :term go run .
        endif
    endfunction
    noremap <Leader>r :call Compile_Run()<CR>

    if LINUX() && !WSL()
        let g:input_toggle = 1

        function! Fcitx2en()
            let s:input_status = system('fcitx-remote')
            if s:input_status == 2
                let g:input_toggle = 1
                let l:a = system('fcitx-remote -c')
            endif
        endfunction

        function! Fcitx2zh()
            let s:input_status = system('fcitx-remote')
            if s:input_status != 2 && g:input_toggle == 1
                let l:a = system('fcitx-remote -o')
                let g:input_toggle = 0
            endif
        endfunction

        set ttimeoutlen=150

        autocmd InsertLeave * call Fcitx2en()
        autocmd InsertEnter * call Fcitx2zh()
    endif
endif
