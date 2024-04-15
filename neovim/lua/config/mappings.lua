local environment = require("utils.environment")
local filetype = require("utils.filetype")
local keymap = require("utils.keymap")
local lsp = require("utils.lsp")
local utils = require("utils")

-- 设置 leader 为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 清除原有 keymap
vim.keymap.set({ "n", "x" }, "<space>", "<nop>", { silent = true })
vim.keymap.set({ "n", "x" }, "s", "<nop>", { silent = true })
vim.keymap.set({ "n", "x" }, "<c-c>", "<nop>", { silent = true })

-- 跳到行首行尾不带空格
vim.keymap.set({ "n", "x", "o" }, "H", "^", { desc = "Start of line (non-blank)", silent = true })
vim.keymap.set({ "n", "x", "o" }, "L", "g_", { desc = "End of line (non-blank)", silent = true })

-- 折行时小步上下移动
local function move(key, set_jumps)
    set_jumps = set_jumps == nil or set_jumps

    local buf = vim.api.nvim_get_current_buf()
    local cursor_center_enabled = vim.g.cursor_center_enabled or false
    if vim.b[buf].cursor_center_enabled ~= nil then
        cursor_center_enabled = vim.b[buf].cursor_center_enabled
    end

    local prefix = ""
    local postfix = ""

    if cursor_center_enabled then
        postfix = postfix .. "zz"
    end

    local count = vim.v.count
    if count > 0 then
        prefix = prefix .. tostring(count)
        if set_jumps then
            vim.cmd("normal! m'")
        end
    end

    if count == 0 and not vim.fn.mode():find("V") then
        vim.cmd.normal(string.format("g%s%s", key, postfix))
    else
        vim.cmd(string.format("normal! %s%s%s", prefix, key, postfix))
    end
end
vim.keymap.set({ "n", "x" }, "j", function() move("j") end, { desc = "Down", silent = true })
vim.keymap.set({ "n", "x" }, "k", function() move("k") end, { desc = "Up", silent = true })

-- 上下移动选中文本
vim.keymap.set("x", "J", ":move '>+1<cr>gv-gv", { desc = "Move selected text up", silent = true })
vim.keymap.set("x", "K", ":move '<-2<cr>gv-gv", { desc = "Move selected text down", silent = true })

-- mark
vim.keymap.set("n", "M", "m", { desc = "Mark", silent = true })

-- 选中上次粘贴的文本
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select last pasted text", silent = true })

-- 调整光标所在行到屏幕的位置
if not utils.is_available("neoscroll.nvim") then
    vim.keymap.set({ "n", "x" }, "zj", "zt", { desc = "Top this line", remap = true, silent = true })
    vim.keymap.set({ "n", "x" }, "zk", "zb", { desc = "Bottom this line", remap = true, silent = true })
end

if environment.is_vscode then
    local vscode = require("vscode-neovim")

    vim.notify = vscode.notify

    -- 注释
    local function esc()
        local key = vim.api.nvim_replace_termcodes("<esc>", true, true, true)
        vim.api.nvim_feedkeys(key, "n", false)
    end
    local comment = vscode.to_op(function(ctx)
        local cmd = "editor.action.commentLine"
        local opts = { range = ctx.range, callback = esc }
        if ctx.is_linewise and ctx.is_current_line then
            opts.range = nil
        end
        vscode.action(cmd, opts)
    end)
    local comment_line = function()
        return comment() .. "_"
    end
    local block_comment = vscode.to_op(function(ctx)
        local cmd = "editor.action.blockComment"
        local opts = { range = ctx.range, callback = esc }
        vscode.action(cmd, opts)
    end)
    local block_comment_line = function()
        return block_comment() .. "_"
    end
    vim.keymap.set({ "n", "x" }, "gc", comment, { expr = true, silent = true })
    vim.keymap.set("n", "gcc", comment_line, { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "gb", block_comment, { expr = true, silent = true })
    vim.keymap.set("n", "gbb", block_comment_line, { expr = true, silent = true })

    -- 转到
    vim.keymap.set("n", "gD", function() vscode.action("editor.action.revealDeclaration") end, { silent = true })
    vim.keymap.set("n", "gi", function() vscode.action("editor.action.goToImplementation") end, { silent = true })
    vim.keymap.set("n", "gr", function() vscode.action("editor.action.goToReferences") end, { silent = true })
    vim.keymap.set("n", "gy", function() vscode.action("editor.action.goToTypeDefinition") end, { silent = true })

    -- 折叠
    vim.keymap.set("n", "zc", function() vscode.action("editor.fold") end, { silent = true })
    vim.keymap.set("n", "zC", function() vscode.action("editor.foldRecursively") end, { silent = true })
    vim.keymap.set("n", "zo", function() vscode.action("editor.unfold") end, { silent = true })
    vim.keymap.set("n", "zO", function() vscode.action("editor.unfoldRecursively") end, { silent = true })
    vim.keymap.set("n", "za", function() vscode.action("editor.toggleFold") end, { silent = true })
    vim.keymap.set("n", "zm", function() vscode.action("editor.foldAll") end, { silent = true })
    vim.keymap.set("n", "zr", function() vscode.action("editor.unfoldAll") end, { silent = true })

    -- 平滑滚动，防止 vscode 产生新的 jumplist
    local scroll_interval = 10
    vim.keymap.set({ "n", "x" }, "<c-d>", function()
        vim.fn.timer_stopall()
        local scroll = vim.api.nvim_get_option_value("scroll", { scope = "local" })
        for i = 1, scroll do
            vim.fn.timer_start(i * scroll_interval, function()
                vim.cmd("normal! j")
            end)
        end
    end, { silent = true })
    vim.keymap.set({ "n", "x" }, "<c-u>", function()
        vim.fn.timer_stopall()
        local scroll = vim.api.nvim_get_option_value("scroll", { scope = "local" })
        for i = 1, scroll do
            vim.fn.timer_start(i * scroll_interval, function()
                vim.cmd("normal! k")
            end)
        end
    end, { silent = true })

    -- 调试
    vim.keymap.set("n", "<leader>dr", function() vscode.action("workbench.action.debug.restart") end, { silent = true })
    vim.keymap.set("n", "<leader>dk", function() vscode.action("workbench.action.debug.callStackUp") end, { silent = true })
    vim.keymap.set("n", "<leader>dj", function() vscode.action("workbench.action.debug.callStackDown") end, { silent = true })
    vim.keymap.set("n", "<leader>dh", function() vscode.action("editor.debug.action.showDebugHover") end, { silent = true })

    -- 格式化
    vim.keymap.set("n", "<leader>f", function()
        if vim.startswith(vim.fn.expand("%:e"), "ipynb") then
            vscode.action("notebook.formatCell")
        else
            vscode.action("editor.action.formatDocument")
        end
    end, { silent = true })

    -- 运行
    vim.keymap.set("n", "<leader>r", function()
        local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        if ft == "html" or ft == "xhtml" then
            vscode.action("office.html.preview")
        elseif ft == "markdown" then
            vscode.action("markdown.showPreviewToSide")
        elseif ft == "tex" then
            vscode.action("latex-workshop.build")
        else
            vscode.action("code-runner.run")
        end
    end, { silent = true })

    -- vscode 扩展
    vim.keymap.set("n", "<leader>p", function() vscode.action("extension.pasteImage") end, { silent = true })
else
    -- 命令行
    vim.keymap.set("c", "<down>", "<c-n>", { desc = "Down", silent = true })
    vim.keymap.set("c", "<up>", "<c-p>", { desc = "Up", silent = true })
    vim.keymap.set("c", "<c-j>", "<c-n>", { desc = "Down", silent = true })
    vim.keymap.set("c", "<c-k>", "<c-p>", { desc = "Up", silent = true })

    -- 新行保持缩进
    if not utils.is_available("ultimate-autopair.nvim") then
        vim.keymap.set("i", "<cr>", "<cr>x<bs>", { desc = "Enter", silent = true })
    end

    -- 折行时小步上下移动
    vim.keymap.set("i", "<down>", function() vim.cmd("normal! gj") end, { desc = "Down", silent = true })
    vim.keymap.set("i", "<up>", function() vim.cmd("normal! gk") end, { desc = "Up", silent = true })

    -- 终端
    vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], { desc = "Enter normal mode", silent = true })

    if not utils.is_available("edgy.nvim") then
        -- 聚焦 left panel
        vim.keymap.set("n", keymap["<c-1>"], function()
            if not filetype.toggle_panel("left") then
                if utils.is_available("neo-tree.nvim") then
                    require("neo-tree.sources.manager").close_all()
                    require("neo-tree.command").execute({ dir = vim.fn.getcwd() })
                elseif utils.is_available("nvim-tree.lua") then
                    require("nvim-tree.api").tree.open()
                end
            end
        end, { desc = "Focus left panel", silent = true })

        -- 聚焦主编辑区域
        vim.keymap.set("n", keymap["<c-2>"], function() filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1) end, { desc = "Focus editor", silent = true })

        -- 聚焦 bottom panel
        vim.keymap.set("n", keymap["<c-3>"], function()
            local count = vim.v.count
            if count > 0 and utils.is_available("toggleterm.nvim") then
                vim.api.nvim_command(tostring(count) .. "ToggleTerm")
                return
            end

            if not filetype.toggle_panel("bottom") then
                if utils.is_available("toggleterm.nvim") then
                    vim.api.nvim_command("ToggleTerm")
                end
            end
        end, { desc = "Focus bottom panel", silent = true })

        -- 聚焦 right panel
        vim.keymap.set("n", keymap["<c-4>"], function()
            if not filetype.toggle_panel("right") then
                vim.api.nvim_command("DocsViewToggle")
            end
        end, { desc = "Focus right panel", silent = true })
    end

    -- 搜索并替换
    vim.keymap.set("n", "<c-f>", ":1,$s///gcI<left><left><left><left><left>", { desc = "Search and replace in file" })
    vim.keymap.set("x", "<c-f>", ":s///gcI<left><left><left><left><left>", { desc = "Search and replace in file" })

    -- 窗口
    vim.keymap.set("n", "<c-e>", function() vim.cmd.wincmd("r") end, { desc = "Exchange window", silent = true })
    vim.keymap.set("n", "<c-j>", function() filetype.skip_filetype(filetype.skip_filetype_list_of_panel, 1) end, { desc = "Move to next window", silent = true })
    vim.keymap.set("n", "<c-k>", function() filetype.skip_filetype(filetype.skip_filetype_list_of_panel, -1) end, { desc = "Move to previous window", silent = true })
    vim.keymap.set("n", "<c-s>h", function()
        local splitright = vim.api.nvim_get_option_value("splitright", { scope = "local" })

        vim.api.nvim_set_option_value("splitright", false, { scope = "local" })
        vim.cmd.wincmd("v")

        vim.api.nvim_set_option_value("splitright", splitright, { scope = "local" })
    end, { desc = "Split window to left", silent = true })
    vim.keymap.set("n", "<c-s>l", function()
        local splitright = vim.api.nvim_get_option_value("splitright", { scope = "local" })

        vim.api.nvim_set_option_value("splitright", true, { scope = "local" })
        vim.cmd.wincmd("v")

        vim.api.nvim_set_option_value("splitright", splitright, { scope = "local" })
    end, { desc = "Split window to right", silent = true })
    vim.keymap.set("n", "<c-s>j", function()
        local splitbelow = vim.api.nvim_get_option_value("splitbelow", { scope = "local" })

        vim.api.nvim_set_option_value("splitbelow", true, { scope = "local" })
        vim.cmd.wincmd("s")

        vim.api.nvim_set_option_value("splitbelow", splitbelow, { scope = "local" })
    end, { desc = "Split window to down", silent = true })
    vim.keymap.set("n", "<c-s>k", function()
        local splitbelow = vim.api.nvim_get_option_value("splitbelow", { scope = "local" })

        vim.api.nvim_set_option_value("splitbelow", false, { scope = "local" })
        vim.cmd.wincmd("s")

        vim.api.nvim_set_option_value("splitbelow", splitbelow, { scope = "local" })
    end, { desc = "Split window to up", silent = true })
    if not utils.is_available("winshift.nvim") then
        vim.keymap.set("n", "<c-s><c-h>", function() vim.cmd.wincmd("H") end, { desc = "Move window to left", silent = true })
        vim.keymap.set("n", "<c-s><c-l>", function() vim.cmd.wincmd("L") end, { desc = "Move window to right", silent = true })
        vim.keymap.set("n", "<c-s><c-j>", function() vim.cmd.wincmd("J") end, { desc = "Move window to down", silent = true })
        vim.keymap.set("n", "<c-s><c-k>", function() vim.cmd.wincmd("K") end, { desc = "Move window to up", silent = true })
    end
    vim.keymap.set("n", "<c-left>", function() vim.cmd.wincmd("<") end, { desc = "Decrease window width", silent = true })
    vim.keymap.set("n", "<c-right>", function() vim.cmd.wincmd(">") end, { desc = "Increase window width", silent = true })
    vim.keymap.set("n", "<c-up>", function() vim.cmd.wincmd("+") end, { desc = "Increase window height", silent = true })
    vim.keymap.set("n", "<c-down>", function() vim.cmd.wincmd("-") end, { desc = "Decrease window height", silent = true })

    -- tab
    vim.keymap.set("n", "<c-h>", function() vim.cmd.tabprevious() end, { desc = "Cycle previous tab", silent = true })
    vim.keymap.set("n", "<c-l>", function() vim.cmd.tabnext() end, { desc = "Cycle next tab", silent = true })
    vim.keymap.set("n", keymap["<c-,>"], function()
        if vim.fn.tabpagenr() > 1 then
            vim.cmd.tabmove("-")
        end
    end, { desc = "Move tab left", silent = true })
    vim.keymap.set("n", keymap["<c-.>"], function()
        if vim.fn.tabpagenr() < vim.fn.tabpagenr("$") then
            vim.cmd.tabmove("+")
        end
    end, { desc = "Move tab right", silent = true })
    vim.keymap.set("n", "<c-s>t", function() vim.api.nvim_command("tab sbuffer") end, { desc = "Copy tab", silent = true })
    vim.keymap.set("n", "<c-s>" .. keymap["<c-,>"], function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.tabprevious()
        vim.api.nvim_command("vertical sbuffer " .. buf)
    end, { desc = "Split buffer to previous tab", silent = true })
    vim.keymap.set("n", "<c-s>" .. keymap["<c-.>"], function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd.tabnext()
        vim.api.nvim_command("vertical sbuffer " .. buf)
    end, { desc = "Split buffer to next tab", silent = true })

    -- 跳转居中
    vim.keymap.set("n", "<c-i>", "<c-i>zz", { desc = "Jump to next location", silent = true })
    vim.keymap.set("n", "<c-o>", "<c-o>zz", { desc = "Jump to previous location", silent = true })

    -- diff
    vim.keymap.set("n", "<c-n>", function()
        vim.cmd("normal! ]c")
        vim.cmd("normal! zz")
    end, { desc = "Next diff", silent = true })
    vim.keymap.set("n", keymap["<c-s-n>"], function()
        vim.cmd("normal! [c")
        vim.cmd("normal! zz")
    end, { desc = "Previous diff", silent = true })

    -- 退出
    vim.keymap.set({ "n", "x" }, "<c-w>", "<cmd>q!<cr><esc>", { desc = "Quit", silent = true })
    vim.keymap.set({ "n", "x" }, "<leader><c-w>", "<cmd>qa!<cr><esc>", { desc = "Quit all", silent = true })

    -- 运行
    vim.keymap.set("n", "<leader>r", function()
        local curr_file = vim.fn.expand("%:~:.")
        local output = vim.fn.expand("%:.:r")
        if environment.is_windows then
            curr_file = curr_file:gsub("\\", "/")
            output = output:gsub("\\", "/") .. ".exe"
        end

        local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        if utils.is_available("toggleterm.nvim") then
            -- TermExec 执行时需要修改 shellslash = true，否则会输出 v:null
            local shellslash = vim.opt.shellslash:get()
            vim.opt.shellslash = true

            if ft == "cpp" then
                -- 若在使用 vector 等库时编译的程序无法运行，可能需要在编译时添加 -static-libstdc++
                -- https://stackoverflow.com/questions/6404636/libstdc-6-dll-not-found/6405064#6405064
                vim.api.nvim_command(string.format([[TermExec cmd='g++ -static-libstdc++ "%s" -o "%s" && ./"%s" && rm ./"%s"']], curr_file, output, output, output))
            elseif ft == "lua" then
                vim.api.nvim_command(string.format([[TermExec cmd='lua "%s"']], curr_file))
            elseif ft == "markdown" then
                if utils.is_available("markdown-preview.nvim") then
                    vim.api.nvim_command("MarkdownPreviewToggle")
                end
            elseif ft == "python" then
                vim.api.nvim_command(string.format([[TermExec cmd='python -u "%s"']], curr_file))
            elseif ft == "rust" then
                vim.api.nvim_command([[TermExec cmd='cargo run']])
            elseif ft == "sh" then
                vim.api.nvim_command(string.format([[TermExec cmd='bash "%s"']], curr_file))
            elseif ft == "tex" then
                if vim.tbl_contains(lsp.lsp_list, "texlab") then
                    vim.api.nvim_command("TexlabBuild")
                end
            end

            vim.opt.shellslash = shellslash
        else
            if ft == "cpp" then
                vim.api.nvim_command(string.format([[g++ -static-libstdc++ "%s" -o "%s" && ./"%s" && rm ./"%s"]], curr_file, output, output, output))
            elseif ft == "lua" then
                vim.api.nvim_command(string.format("luafile %s", curr_file))
            elseif ft == "markdown" then
                if utils.is_available("markdown-preview.nvim") then
                    vim.api.nvim_command("MarkdownPreviewToggle")
                end
            elseif ft == "python" then
                vim.api.nvim_command(string.format("python -u %s", curr_file))
            elseif ft == "rust" then
                vim.api.nvim_command("cargo run")
            elseif ft == "sh" then
                vim.api.nvim_command(string.format("bash %s", curr_file))
            elseif ft == "tex" then
                if vim.tbl_contains(lsp.lsp_list, "texlab") then
                    vim.api.nvim_command("TexlabBuild")
                end
            end
        end
    end, { desc = "Run", silent = true })
end
