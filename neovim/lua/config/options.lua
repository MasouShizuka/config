local environment = require("utils.environment")
local utils = require("utils")

-- Char
vim.opt.list = true                                                                                     -- show <Tab> and <EOL>
vim.opt.listchars:append({
    nbsp = "␣",
    tab = ">~",
    trail = "·",
})                                                                                                      -- characters for displaying in list mode
if not environment.is_vscode then
    utils.fix_cellwidths()
end

-- Clipboard
vim.opt.clipboard = "unnamedplus"                                                                       -- use the clipboard as the unnamed register

-- Column
vim.opt.fillchars:append({ eob = " " })                                                                 -- characters to use for displaying special items
vim.opt.number = true                                                                                   -- print the line number in front of each line
vim.opt.relativenumber = true                                                                           -- show relative line number in front of each line

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }                                     -- options for Insert mode completion
vim.opt.infercase = true                                                                                -- adjust case of match for keyword completion
vim.opt.shortmess:append({ s = true, I = true })                                                        -- list of flags, reduce length of messages

-- Confirm
vim.opt.confirm = true                                                                                  -- ask what to do about unsaved/read-only files

-- Cursor
vim.opt.cursorline = true                                                                               -- highlight the screen line of the cursor

-- Diff
vim.opt.diffopt:append("linematch:60")                                                                  -- options for using diff mode

-- Encoding
vim.opt.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,cp932,cp949,latin1"                           -- automatically detected character encodings

-- File
vim.opt.writebackup = false                                                                             -- make a backup before overwriting a file
vim.opt.shada = ""                                                                                      -- use .shada file upon startup and exiting
vim.opt.swapfile = false                                                                                -- whether to use a swapfile for a buffer

-- Edit
vim.opt.virtualedit = "block"                                                                           -- when to use virtual editing

-- Format
vim.opt.formatoptions = "qjl1"                                                                          -- how automatic formatting is to be done

-- Gui
vim.opt.cmdheight = 0                                                                                   -- number of lines to use for the command-line
vim.opt.pumheight = 10                                                                                  -- maximum number of items to show in the popup menu
vim.opt.termguicolors = true                                                                            -- enables 24-bit RGB color in the TUI

-- Indent
vim.opt.breakindent = true                                                                              -- wrapped line repeats indent
vim.opt.smartindent = true                                                                              -- smart autoindenting for C programs

-- Location list
vim.opt.jumpoptions = "stack"                                                                           -- specifies how jumping is done

-- Mouse
vim.opt.mouse = "a"                                                                                     -- enable the use of mouse clicks

-- Search
vim.opt.ignorecase = true                                                                               -- ignore case in search patterns
vim.opt.maxmempattern = 2000000                                                                         -- maximum memory (in Kbyte) used for pattern search
vim.opt.smartcase = true                                                                                -- no ignore case when pattern has uppercase

-- Tab
vim.opt.expandtab = true                                                                                -- use spaces when <Tab> is inserted
vim.opt.shiftround = true                                                                               -- round indent to multiple of shiftwidth
vim.opt.shiftwidth = 4                                                                                  -- number of spaces to use for (auto)indent step
vim.opt.softtabstop = 4                                                                                 -- number of spaces that <Tab> uses while editing
vim.opt.tabstop = 4                                                                                     -- number of spaces that <Tab> in file uses

-- Keyword
vim.opt.iskeyword:append("-")                                                                           -- characters included in keywords

-- Scrolloff
vim.opt.scrolloff = 5                                                                                   -- minimum nr. of lines above and below cursor
vim.opt.sidescrolloff = 5                                                                               -- min. nr. of columns to left and right of cursor

-- Session
vim.opt.sessionoptions = { "curdir", "folds", "globals", "help", "localoptions", "tabpages", "winsize"} -- options for :mksession

-- Shell
if environment.is_windows then
    vim.opt.shell = "pwsh -NoLogo"                                                                      -- name of shell to use for external commands
    vim.opt.shellcmdflag = "-Command"                                                                   -- flag to shell to execute one command
    vim.opt.shellpipe  = "2>&1 | %%{ '$_' } | tee %s; exit $LastExitCode"                               -- string to put output of ":make" in error file
    vim.opt.shellquote = ""                                                                             -- quote character(s) for around shell command
    vim.opt.shellslash = true                                                                           -- use forward slash for shell file names
    vim.opt.shellredir = "2>&1 | %%{ '$_' } | Out-File %s; exit $LastExitCode"                          -- string to put output of filter in a temp file
    vim.opt.shellxquote = ""                                                                            -- like 'shellquote', but include redirection
    -- vim.opt.shell = "C:/msys64/usr/bin/zsh.exe"                                                      -- name of shell to use for external commands
    -- vim.opt.shellcmdflag = "-c"                                                                      -- flag to shell to execute one command
    -- vim.opt.shellslash = true                                                                        -- use forward slash for shell file names
    -- vim.opt.shellxquote = ""                                                                         -- like 'shellquote', but include redirection
end

-- Spell
vim.opt.spelllang = "en,cjk"                                                                            -- language(s) to do spell checking for

-- Split window
vim.opt.splitbelow = true                                                                               -- new window from split is below the current one
vim.opt.splitright = true                                                                               -- new window is put right of the current one

-- Status line
vim.opt.ruler = false                                                                                   -- show cursor line and column in the status line
vim.opt.showtabline = 2                                                                                 -- tells when the tab pages line is displayed
vim.opt.showmode = false                                                                                -- message on status line to show current mode

-- Time
if not environment.is_vscode then
    vim.opt.timeoutlen = 500                                                                            -- time out time in milliseconds
end
vim.opt.updatetime = 300                                                                                -- after this many milliseconds flush swap file

-- Wildmenu
vim.opt.wildmode = "longest:list,full"                                                                  -- mode for 'wildchar' command-line expansion

-- Wrap
vim.opt.linebreak = true                                                                                -- wrap long lines at a blank
vim.opt.wrap = false                                                                                    -- long lines wrap and continue on the next line
