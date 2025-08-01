local M = {}

function M.setup(opts)
    local environment = require("utils.environment")
    local icons = require("utils.icons")
    local utils = require("utils")

    -- Char
    vim.opt.list = true -- show <Tab> and <EOL>
    vim.opt.listchars:append({
        nbsp = "␣",
        tab = ">~",
        trail = "·",
    }) -- characters for displaying in list mode

    -- Clipboard
    if environment.is_wsl then
        vim.g.clipboard = {
            name = "WslClipboard",
            copy = {
                ["+"] = "clip.exe",
                ["*"] = "clip.exe",
            },
            paste = {
                ["+"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                ["*"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
            cache_enabled = 0,
        }
    end

    -- Completion
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" } -- options for Insert mode completion
    vim.opt.infercase = true                                            -- adjust case of match for keyword completion

    -- Cursor
    vim.opt.cursorline = true -- highlight the screen line of the cursor

    -- Diff
    vim.opt.diffopt = vim.list_extend(vim.opt.diffopt:get(), { "algorithm:histogram", "linematch:60" }) -- options for using diff mode

    -- Encoding
    vim.opt.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,cp932,cp949,latin1" -- automatically detected character encodings

    -- File
    vim.opt.writebackup = false -- make a backup before overwriting a file
    vim.opt.shada = ""          -- use .shada file upon startup and exiting
    vim.opt.shadafile = "NONE"  -- disable .shada file
    vim.opt.swapfile = false    -- whether to use a swapfile for a buffer

    -- Fold
    -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/ui.lua
    -- https://github.com/AstroNvim/astroui/blob/main/lua/astroui/folding.lua
    function _G.custom_foldexpr(lnum)
        local bufnr = vim.api.nvim_get_current_buf()
        for _, fold_method in ipairs({
            function(lnum, bufnr)
                if vim.b[bufnr].ts_folds == nil then
                    -- as long as we don't have a filetype, don't bother
                    -- checking if treesitter is available (it won't)
                    if vim.bo[bufnr].filetype == "" then
                        return "0"
                    end
                    if vim.bo[bufnr].filetype:find("dashboard") then
                        vim.b[bufnr].ts_folds = false
                    else
                        vim.b[bufnr].ts_folds = pcall(vim.treesitter.get_parser, bufnr)
                    end
                end
                if vim.b[bufnr].ts_folds then
                    return vim.treesitter.foldexpr(lnum)
                end
            end,
            function(lnum, bufnr)
                if not lnum then
                    lnum = vim.v.lnum
                end

                local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
                if line:match("^%s*$") then
                    return "="
                end

                local function indent_value(lnum)
                    return math.floor(vim.fn.indent(lnum) / vim.fn.shiftwidth())
                end

                local value = indent_value(lnum)

                local line_count = vim.api.nvim_buf_line_count(bufnr)
                if lnum == line_count then
                    return tostring(value)
                end

                local next_value = indent_value(lnum + 1)
                if value < next_value then
                    return ">" .. tostring(value + 1)
                end
                if value > next_value then
                    return "<" .. tostring(value)
                end

                return tostring(value)
            end,
        }) do
            local fold = fold_method(lnum, bufnr)
            if fold then
                return fold
            end
        end
        -- fallback to no folds
        return "0"
    end

    -- https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
    local function foldtext()
        local pos = vim.v.foldstart
        local line = vim.api.nvim_buf_get_lines(0, pos - 1, pos, false)[1]

        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        if not vim.b[buf].ts_folds and vim.wo[win][0].foldexpr ~= "v:lua.vim.lsp.foldexpr()" then
            return line
        end

        local result = {}

        local text = ""
        local hl
        for i = 1, #line do
            local char = line:sub(i, i)
            local hls = vim.treesitter.get_captures_at_pos(buf, pos - 1, i - 1)
            local _hl = hls[#hls]
            if _hl then
                local new_hl = "@" .. _hl.capture
                if new_hl ~= hl then
                    table.insert(result, { text, hl })
                    text = ""
                    hl = nil
                end
                text = text .. char
                hl = new_hl
            else
                text = text .. char
            end
        end
        table.insert(result, { text, hl })

        return result
    end
    function _G.custom_foldtext()
        local result = foldtext()
        if type(result) == "string" then
            result = { { result } }
        end
        table.insert(result, { string.format(" 󰁂 %s", vim.v.foldend - vim.v.foldstart), "DiagnosticError" })
        return result
    end

    vim.opt.foldcolumn = "1"                     -- width of the column used to indicate folds
    vim.opt.foldexpr = "v:lua.custom_foldexpr()" -- expression used when 'foldmethod' is "expr"
    vim.opt.foldlevel = 99                       -- close folds with a level higher than this
    vim.opt.foldlevelstart = 99                  -- 'foldlevel' when starting to edit a file
    vim.opt.foldmethod = "expr"                  -- folding type
    vim.opt.foldtext = "v:lua.custom_foldtext()" -- expression used to display for a closed fold

    -- Edit
    vim.opt.virtualedit = "block" -- when to use virtual editing

    -- Format
    vim.opt.formatoptions = "rqlmB1j" -- how automatic formatting is to be done

    -- Gui
    if not environment.is_vscode then
        vim.opt.cmdheight = 0    -- number of lines to use for the command-line
    end
    vim.opt.pumheight = 10       -- maximum number of items to show in the popup menu
    vim.opt.termguicolors = true -- enables 24-bit RGB color in the TUI
    vim.opt.title = true         -- let Vim set the title of the window
    vim.opt.titlestring = "%t"   -- string to use for the Vim window title

    -- Indent
    vim.opt.breakindent = true -- wrapped line repeats indent
    vim.opt.smartindent = true -- smart autoindenting for C programs

    -- Location list
    vim.opt.jumpoptions = "stack" -- specifies how jumping is done

    -- Mouse
    vim.opt.mouse = "a" -- enable the use of mouse clicks

    -- Search
    vim.opt.ignorecase = true       -- ignore case in search patterns
    vim.opt.maxmempattern = 2000000 -- maximum memory (in Kbyte) used for pattern search
    vim.opt.smartcase = true        -- no ignore case when pattern has uppercase

    -- Tab
    vim.opt.expandtab = true -- use spaces when <Tab> is inserted
    vim.opt.shiftwidth = 0   -- number of spaces to use for (auto)indent step
    vim.opt.softtabstop = 4  -- number of spaces that <Tab> uses while editing
    vim.opt.tabstop = 4      -- number of spaces that <Tab> in file uses

    -- Keyword
    vim.opt.iskeyword:append("-") -- characters included in keywords

    -- Scrolloff
    vim.opt.scrolloff = 5     -- minimum nr. of lines above and below cursor
    vim.opt.sidescrolloff = 5 -- min. nr. of columns to left and right of cursor

    -- Session
    vim.opt.sessionoptions = { "curdir", "folds", "globals", "help", "localoptions", "tabpages", "winsize" } -- options for :mksession

    -- Shell
    if environment.is_windows then
        vim.opt.shell = "ucrt64.cmd"
        vim.opt.shellcmdflag = "-c"
        vim.opt.shellxquote = ""
    end

    -- Spell
    vim.opt.spelllang = { "en", "cjk" } -- language(s) to do spell checking for

    -- Split window
    vim.opt.splitbelow = true -- new window from split is below the current one
    vim.opt.splitright = true -- new window is put right of the current one

    -- Statuscolumn
    vim.opt.fillchars:append({
        eob = " ",
        fold = " ",
        foldclose = icons.fold.FoldClosed,
        foldopen = icons.fold.FoldOpened,
        foldsep = icons.fold.FoldSeparator,
    })                            -- characters to use for displaying special items
    vim.opt.number = true         -- print the line number in front of each line
    vim.opt.relativenumber = true -- show relative line number in front of each line

    -- Statusline
    vim.opt.confirm = true                           -- ask what to do about unsaved/read-only files
    if utils.is_available("edgy.nvim") then
        vim.opt.laststatus = 3                       -- tells when last window has status lines
    end
    vim.opt.ruler = false                            -- show cursor line and column in the status line
    vim.opt.shortmess:append({ s = true, I = true }) -- list of flags, reduce length of messages
    vim.opt.showtabline = 2                          -- tells when the tab pages line is displayed
    if utils.is_available("heirline.nvim") then
        vim.opt.showcmdloc = "statusline"            -- where to show (partial) command
    end
    vim.opt.showmode = false                         -- message on status line to show current mode

    -- Time
    if not environment.is_vscode then
        vim.opt.timeoutlen = 1000 -- time out time in milliseconds
    end
    vim.opt.updatetime = 300      -- after this many milliseconds flush swap file

    -- Wildmenu
    vim.opt.wildmode = "longest:list,full" -- mode for 'wildchar' command-line expansion

    -- Wrap
    vim.opt.linebreak = true    -- wrap long lines at a blank
    vim.opt.smoothscroll = true -- scroll by screen lines when 'wrap' is set
    vim.opt.wrap = false        -- long lines wrap and continue on the next line
end

return M
