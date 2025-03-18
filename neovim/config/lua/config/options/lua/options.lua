local M = {}

function M.setup(opts)
    local environment = require("utils.environment")
    local icons = require("utils.icons")
    local utils = require("utils")

    -- Char
    vim.opt.list = true                                                                                     -- show <Tab> and <EOL>
    vim.opt.listchars:append({
        nbsp = "␣",
        tab = ">~",
        trail = "·",
    })                                                                                                      -- characters for displaying in list mode

    -- Clipboard
    vim.opt.clipboard = "unnamedplus"                                                                       -- use the clipboard as the unnamed register
    if environment.is_wsl then
        vim.g.clipboard = {
            name = "WslClipboard",
            copy = {
                ["+"] = "clip.exe",
                ["*"] = "clip.exe",
            },
            paste = {
                ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
        }
    end

    -- Column
    vim.opt.fillchars:append({
        eob = " ",
        fold = " ",
        foldclose = icons.fold.FoldClosed,
        foldopen = icons.fold.FoldOpened,
        foldsep = icons.fold.FoldSeparator,
    })                                                                                                      -- characters to use for displaying special items
    vim.opt.number = true                                                                                   -- print the line number in front of each line
    vim.opt.relativenumber = true                                                                           -- show relative line number in front of each line

    -- Completion
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }                                     -- options for Insert mode completion
    vim.opt.infercase = true                                                                                -- adjust case of match for keyword completion

    -- Cursor
    vim.opt.cursorline = true                                                                               -- highlight the screen line of the cursor

    -- Diff
    vim.opt.diffopt = vim.list_extend(vim.opt.diffopt:get(), { "algorithm:histogram", "linematch:60" })     -- options for using diff mode

    -- Encoding
    vim.opt.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,cp932,cp949,latin1"                           -- automatically detected character encodings

    -- File
    vim.opt.writebackup = false                                                                             -- make a backup before overwriting a file
    vim.opt.shada = ""                                                                                      -- use .shada file upon startup and exiting
    vim.opt.shadafile = "NONE"                                                                              -- disable .shada file
    vim.opt.swapfile = false                                                                                -- whether to use a swapfile for a buffer

    -- Fold
    if utils.is_available("nvim-ufo") then
        vim.opt.foldcolumn = "1"                                                                            -- width of the column used to indicate folds
        vim.opt.foldlevel = 99                                                                              -- close folds with a level higher than this
        vim.opt.foldlevelstart = 99                                                                         -- 'foldlevel' when starting to edit a file
    end

    -- Edit
    vim.opt.virtualedit = "block"                                                                           -- when to use virtual editing

    -- Format
    vim.opt.formatoptions = "rqlmB1j"                                                                       -- how automatic formatting is to be done

    -- Gui
    if not environment.is_vscode then
        vim.opt.cmdheight = 0                                                                               -- number of lines to use for the command-line
    end
    vim.opt.pumheight = 10                                                                                  -- maximum number of items to show in the popup menu
    vim.opt.termguicolors = true                                                                            -- enables 24-bit RGB color in the TUI
    vim.opt.title = true                                                                                    -- let Vim set the title of the window
    vim.opt.titlestring = "%t"                                                                              -- string to use for the Vim window title

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
    vim.opt.shiftwidth = 0                                                                                  -- number of spaces to use for (auto)indent step
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
        -- shellslash 不能直接修改，否则会导致 windows 下 friendly-snippets 等失效

        -- vim.opt.shell = "pwsh -NoLogo"
        -- vim.opt.shellcmdflag = "-Command"
        -- vim.opt.shellpipe  = "2>&1 | %%{ '$_' } | tee %s; exit $LastExitCode"
        -- vim.opt.shellquote = ""
        -- vim.opt.shellredir = "2>&1 | %%{ '$_' } | Out-File %s; exit $LastExitCode"
        -- vim.opt.shellxquote = ""

        vim.opt.shell = "ucrt64.cmd"
        vim.opt.shellcmdflag = "-c"
        vim.opt.shellxquote = ""
    end

    -- Spell
    vim.opt.spelllang = { "en", "cjk" }                                                                     -- language(s) to do spell checking for

    -- Split window
    vim.opt.splitbelow = true                                                                               -- new window from split is below the current one
    vim.opt.splitright = true                                                                               -- new window is put right of the current one

    -- Status line
    vim.opt.confirm = true                                                                                  -- ask what to do about unsaved/read-only files
    if utils.is_available("edgy.nvim") then
        vim.opt.laststatus = 3                                                                              -- tells when last window has status lines
    end
    vim.opt.ruler = false                                                                                   -- show cursor line and column in the status line
    vim.opt.shortmess:append({ s = true, I = true })                                                        -- list of flags, reduce length of messages
    vim.opt.showtabline = 2                                                                                 -- tells when the tab pages line is displayed
    if utils.is_available("heirline.nvim") then
        vim.opt.showcmdloc = "statusline"                                                                   -- where to show (partial) command
    end
    vim.opt.showmode = false                                                                                -- message on status line to show current mode

    -- Time
    if not environment.is_vscode then
        vim.opt.timeoutlen = 1000                                                                           -- time out time in milliseconds
    end
    vim.opt.updatetime = 300                                                                                -- after this many milliseconds flush swap file

    -- Wildmenu
    vim.opt.wildmode = "longest:list,full"                                                                  -- mode for 'wildchar' command-line expansion

    -- Wrap
    vim.opt.linebreak = true                                                                                -- wrap long lines at a blank
    vim.opt.smoothscroll = true                                                                             -- scroll by screen lines when 'wrap' is set
    vim.opt.wrap = false                                                                                    -- long lines wrap and continue on the next line
end

return M
