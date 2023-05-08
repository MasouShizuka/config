local variables = require("variables")

-- Char
vim.opt.list = true                                                                -- show <Tab> and <EOL>
vim.opt.listchars:append({
    extends = "…",
    nbsp = "␣",
    precedes = "…",
    tab = ">~",
    trail = "·",
})                                                                                 -- characters for displaying in list mode

-- Clipboard
vim.opt.clipboard = "unnamedplus"                                                  -- use the clipboard as the unnamed register

-- Column
vim.opt.fillchars:append({ eob = " " })                                            -- characters to use for displaying special items
vim.opt.number = true                                                              -- print the line number in front of each line
vim.opt.relativenumber = true                                                      -- show relative line number in front of each line
vim.opt.signcolumn = "yes"                                                         -- when and how to display the sign column

-- Completion
vim.opt.completeopt = { "menuone", "noinsert", "noinsert" }                        -- options for Insert mode completion
vim.opt.infercase = true                                                           -- adjust case of match for keyword completion
vim.opt.shortmess:append("cCIW")                                                   -- list of flags, reduce length of messages

-- Confirm
vim.opt.confirm = true                                                             -- ask what to do about unsaved/read-only files

-- Cursor
vim.opt.cursorline = true                                                          -- highlight the screen line of the cursor

-- File
vim.opt.writebackup = false                                                        -- make a backup before overwriting a file
vim.opt.shada = ""                                                                 -- use .shada file upon startup and exiting
vim.opt.swapfile = false                                                           -- whether to use a swapfile for a buffer

-- Edit
vim.opt.virtualedit = "block"                                                      -- when to use virtual editing

-- Format
vim.opt.formatoptions = "qjl1"                                                     -- how automatic formatting is to be done

-- Gui
vim.opt.cmdheight = 0                                                              -- number of lines to use for the command-line
vim.opt.pumblend = 0                                                               -- enables pseudo-transparency for the popup-menu
vim.opt.pumheight = 10                                                             -- maximum number of items to show in the popup menu
vim.opt.termguicolors = true                                                       -- enables 24-bit RGB color in the TUI
vim.opt.winblend = 0                                                               -- enables pseudo-transparency for a floating window.

-- Indent
vim.opt.breakindent = true                                                         -- wrapped line repeats indent
vim.opt.linebreak = true                                                           -- wrap long lines at a blank
vim.opt.smartindent = true                                                         -- smart autoindenting for C programs

-- Location list
vim.opt.jumpoptions = "stack"                                                      -- specifies how jumping is done

-- Mouse
vim.opt.mouse = "a"                                                                -- enable the use of mouse clicks

-- Search
vim.opt.ignorecase = true                                                          -- ignore case in search patterns
vim.opt.smartcase = true                                                           -- no ignore case when pattern has uppercase

-- Tab
vim.opt.expandtab = true                                                           -- use spaces when <Tab> is inserted
vim.opt.shiftround = true                                                          -- round indent to multiple of shiftwidth
vim.opt.shiftwidth = 4                                                             -- number of spaces to use for (auto)indent step
vim.opt.softtabstop = 4                                                            -- number of spaces that <Tab> uses while editing
vim.opt.tabstop = 4                                                                -- number of spaces that <Tab> in file uses

-- Keyword
vim.opt.iskeyword:append("-")                                                      -- characters included in keywords

-- Scrolloff
vim.opt.scrolloff = 5                                                              -- minimum nr. of lines above and below cursor
vim.opt.sidescrolloff = 5                                                          -- min. nr. of columns to left and right of cursor

-- Session
vim.opt.sessionoptions = "curdir,folds,globals,help,localoptions,tabpages,winsize" -- options for :mksession

-- Shell
if variables.is_windows then
    vim.opt.shell = "pwsh -nologo"                                                 -- name of shell to use for external commands
    vim.opt.shellcmdflag = "-c"                                                    -- flag to shell to execute one command
    vim.opt.shellquote = ""                                                        -- quote character(s) for around shell command
    vim.opt.shellxquote = ""                                                       -- like 'shellquote', but include redirection
end

-- Split window
vim.opt.splitbelow = true                                                          -- new window from split is below the current one
vim.opt.splitkeep = "screen"                                                       -- determines scroll behavior for split windows
vim.opt.splitright = true                                                          -- new window is put right of the current one

-- Status line
vim.opt.ruler = false                                                              -- show cursor line and column in the status line
vim.opt.showtabline = 2                                                            -- tells when the tab pages line is displayed
vim.opt.showmode = false                                                           -- message on status line to show current mode

-- Time
vim.opt.timeoutlen = 1000                                                          -- time out time in milliseconds
vim.opt.updatetime = 1000                                                          -- after this many milliseconds flush swap file

-- Wildmenu
vim.opt.wildmode = "longest:list,full"                                             -- mode for 'wildchar' command-line expansion
