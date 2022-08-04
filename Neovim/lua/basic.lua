local os_name = vim.loop.os_uname().sysname

function is_windows()
    return os_name == "Windows_NT"
end

function is_macos()
    return os_name == "Darwin"
end

function is_linux()
    return os_name == "Linux"
end



-- 当文件被外部程序修改时，自动加载
vim.opt.autoread = true

-- 新行对齐当前行
vim.opt.autoindent = true
vim.opt.smartindent = true

-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.shada = nil

-- 剪切板
vim.opt.clipboard = "unnamedplus"

-- 自动补全不自动选中
vim.opt.completeopt = "menu,menuone,noselect,noinsert"
-- 补全最多显示10行
vim.opt.pumheight = 10

-- 高亮所在行
vim.opt.cursorline = true

-- 编码
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "utf-8,gb2312,gbk,cp936,latin-1"
vim.opt.termencoding = "utf-8"

-- 4个空格等于一个Tab
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftround = true
vim.opt.shiftwidth = 4

-- 允许隐藏被修改过的buffer
vim.opt.hidden = true

-- 搜索高亮，边输入边搜索
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 搜索大小写不敏感，除非包含大写
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 鼠标支持
vim.opt.mouse = "a"

-- 相对行号
vim.opt.number = true
vim.opt.relativenumber = true

-- 光标周围保留5行
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- 显示左侧图标指示列
vim.opt.signcolumn = "yes"
-- 右侧参考线，超过表示代码太长了，考虑换行
vim.opt.colorcolumn = "88"

-- 永远显示 tabline
vim.opt.showtabline = 2
-- 使用增强状态栏插件后不再需要 vim 的模式提示
vim.opt.showmode = false

-- split window 从下边和右边出现
vim.opt.splitbelow = true
vim.opt.splitright = true

-- smaller updatetime
vim.opt.updatetime = 300
-- 设置 timeoutlen 为等待键盘快捷键连击时间500毫秒
vim.opt.timeoutlen = 500

-- 补全增强
vim.opt.wildmenu = true

-- 文件格式
if is_windows() then
    vim.opt.fileformat = "dos"
elseif is_linux() then
    vim.opt.fileformat = "unix"
end

-- filetype
vim.cmd [[
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
]]
