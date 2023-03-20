-- 新行对齐当前行
vim.opt.autoindent = true
vim.opt.smartindent = true

-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.shada = ""
vim.opt.swapfile = false
vim.opt.undofile = false

-- 剪切板
vim.opt.clipboard = "unnamedplus"

-- 命令行高
vim.opt.cmdheight = 1

-- 自动补全不自动选中
vim.opt.completeopt = { "menuone", "noselect" }
-- 补全最多显示10行
vim.opt.pumheight = 10

-- 高亮所在行
vim.opt.cursorline = true

-- 编码
vim.opt.fileencoding = "utf-8"

-- 4个空格等于一个Tab
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftround = true
vim.opt.shiftwidth = 4

-- 搜索高亮，边输入边搜索
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 搜索大小写不敏感，除非包含大写
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 关键字
vim.opt.iskeyword:append("-")

-- 显示字符
vim.opt.list = true
vim.opt.listchars:append "tab:··,trail:·"

-- 鼠标支持
vim.opt.mouse = "a"

-- 相对行号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4

-- 光标周围保留5行
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5

-- 显示左侧图标指示列
vim.opt.signcolumn = "yes"

-- Dont' pass messages to ins-completin menu
vim.opt.shortmess:append("c")

-- 永远显示 tabline
vim.opt.showtabline = 2
-- 使用增强状态栏插件后不再需要 vim 的模式提示
vim.opt.showmode = false

-- split window 从下边和右边出现
vim.opt.splitbelow = true
vim.opt.splitright = true

-- 样式
vim.opt.termguicolors = true

-- 等待键盘快捷键连击时间
vim.opt.timeoutlen = 1000
-- updatetime
vim.opt.updatetime = 1000

-- 超过屏幕长度换行
vim.opt.wrap = true
