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
vim.keymap.set({ "n", "x" }, "j", function() utils.move("j") end, { desc = "Down", silent = true })
vim.keymap.set({ "n", "x" }, "k", function() utils.move("k") end, { desc = "up", silent = true })

-- 上下移动选中文本
vim.keymap.set("x", "J", ":move '>+1<cr>gv-gv", { desc = "Move selected text up", silent = true })
vim.keymap.set("x", "K", ":move '<-2<cr>gv-gv", { desc = "Move selected text down", silent = true })

-- mark
vim.keymap.set("n", "M", "m", { desc = "Mark", silent = true })

-- 选中上次粘贴的文本
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select last pasted text", silent = true })

-- 调整光标所在行到屏幕的位置
vim.keymap.set({ "n", "x" }, "zj", "zt", { desc = "Top this line", remap = true, silent = true })
vim.keymap.set({ "n", "x" }, "zk", "zb", { desc = "Bottom this line", remap = true, silent = true })

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
    local scroll_lines = 20
    vim.keymap.set({ "n", "x" }, "<c-d>", function()
        vim.fn.timer_stopall()
        for i = 1, scroll_lines do
            vim.fn.timer_start(i * scroll_interval, function()
                vim.cmd("normal! j")
            end)
        end
    end, { silent = true })
    vim.keymap.set({ "n", "x" }, "<c-u>", function()
        vim.fn.timer_stopall()
        for i = 1, scroll_lines do
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
        if vim.fn.expand("%:e"):sub(1, 5) == "ipynb" then
            vscode.action("notebook.formatCell")
        else
            vscode.action("editor.action.formatDocument")
        end
    end, { silent = true })

    -- 运行
    vim.keymap.set("n", "<leader>r", function()
        local ft = vim.bo.filetype
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
    vim.keymap.set("i", "<down>", "<c-o>gj", { desc = "Down", silent = true })
    vim.keymap.set("i", "<up>", "<c-o>gk", { desc = "Up", silent = true })

    -- 终端
    vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], { desc = "Enter normal mode", silent = true })

    if not utils.is_available("edgy.nvim") then
        -- 聚焦左侧边栏
        vim.keymap.set("n", keymap["<c-1>"], function()
            if not filetype.toggle_filetype(filetype.toggle_filetype_list_of_left) then
                if utils.is_available("neo-tree.nvim") then
                    require("neo-tree.sources.manager").close_all()
                    require("neo-tree.command").execute({ dir = vim.fn.getcwd() })
                elseif utils.is_available("nvim-tree.lua") then
                    require("nvim-tree.api").tree.open()
                end
            end
        end, { desc = "Focus left panel", silent = true })

        -- 聚焦编辑文件
        vim.keymap.set("n", keymap["<c-2>"], function()
            filetype.skip_filetype(filetype.skip_filetype_list_to_main, "W")
        end, { desc = "Focus editor", silent = true })

        -- 聚焦底栏
        vim.keymap.set("n", keymap["<c-3>"], function()
            local count = vim.v.count
            if count > 0 and utils.is_available("toggleterm.nvim") then
                vim.api.nvim_command(tostring(count) .. "ToggleTerm")
                return
            end

            if not filetype.toggle_filetype(filetype.toggle_filetype_list_of_bottom) then
                if utils.is_available("toggleterm.nvim") then
                    vim.api.nvim_command("ToggleTerm")
                end
            end
        end, { desc = "Focus bottom panel", silent = true })

        -- 聚焦右侧边栏
        vim.keymap.set("n", keymap["<c-4>"], function()
            if not filetype.toggle_filetype(filetype.toggle_filetype_list_of_right) then
                vim.api.nvim_command("DocsViewToggle")
            end
        end, { desc = "Focus right panel", silent = true })
    end

    -- 搜索并替换
    vim.keymap.set("n", "<c-f>", ":1,$s///gcI<left><left><left><left><left>", { desc = "Search and replace in file" })
    vim.keymap.set("x", "<c-f>", ":s///gcI<left><left><left><left><left>", { desc = "Search and replace in file" })

    -- 窗口
    vim.keymap.set("n", "<c-e>", function() vim.cmd.wincmd("r") end, { desc = "Exchange window", silent = true })
    vim.keymap.set("n", "<c-j>", function()
        vim.cmd.wincmd("w")
        filetype.skip_filetype(filetype.skip_filetype_list_of_panel, "w")
    end, { desc = "Move to next window", silent = true })
    vim.keymap.set("n", "<c-k>", function()
        vim.cmd.wincmd("W")
        filetype.skip_filetype(filetype.skip_filetype_list_of_panel, "W")
    end, { desc = "Move to previous window", silent = true })
    vim.keymap.set("n", "<c-s>h", function()
        vim.api.nvim_set_option_value("splitright", false, {})
        vim.cmd.wincmd("v")
    end, { desc = "Split window to left", silent = true })
    vim.keymap.set("n", "<c-s>l", function()
        vim.api.nvim_set_option_value("splitright", true, {})
        vim.cmd.wincmd("v")
    end, { desc = "Split window to right", silent = true })
    vim.keymap.set("n", "<c-s>j", function()
        vim.api.nvim_set_option_value("splitbelow", true, {})
        vim.cmd.wincmd("s")
    end, { desc = "Split window to down", silent = true })
    vim.keymap.set("n", "<c-s>k", function()
        vim.api.nvim_set_option_value("splitbelow", false, {})
        vim.cmd.wincmd("s")
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
    vim.keymap.set("n", "<c-h>", function() vim.cmd.tabprevious() end, { desc = "Cycle next tab", silent = true })
    vim.keymap.set("n", "<c-l>", function() vim.cmd.tabnext() end, { desc = "Cycle previous tab", silent = true })
    vim.keymap.set("n", keymap["<c-,>"], function() vim.cmd.tabmove("-") end, { desc = "Move tab left", silent = true })
    vim.keymap.set("n", keymap["<c-.>"], function() vim.cmd.tabmove("+") end, { desc = "Move tab right", silent = true })
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
        local curr_file_path = vim.fn.expand("%:~:.")
        if environment.is_windows then
            curr_file_path = curr_file_path:gsub("\\", "/")
        end

        local ft = vim.bo.filetype
        if utils.is_available("toggleterm.nvim") then
            if ft == "lua" then
                vim.api.nvim_command(([[TermExec cmd='lua "%s"']]):format(curr_file_path))
            elseif ft == "markdown" then
                if utils.is_available("markdown-preview.nvim") then
                    vim.api.nvim_command("MarkdownPreviewToggle")
                end
            elseif ft == "python" then
                vim.api.nvim_command(([[TermExec cmd='python -u "%s"']]):format(curr_file_path))
            elseif ft == "rust" then
                vim.api.nvim_command([[TermExec cmd='cargo run']])
            elseif ft == "sh" then
                vim.api.nvim_command(([[TermExec cmd='bash "%s"']]):format(curr_file_path))
            elseif ft == "tex" then
                if vim.tbl_contains(lsp.lsp_list, "texlab") then
                    vim.api.nvim_command("TexlabBuild")
                end
            end
        else
            if ft == "lua" then
                vim.api.nvim_command("luafile %")
            elseif ft == "markdown" then
                if utils.is_available("markdown-preview.nvim") then
                    vim.api.nvim_command("MarkdownPreviewToggle")
                end
            elseif ft == "python" then
                vim.api.nvim_command("python -u %")
            elseif ft == "rust" then
                vim.api.nvim_command("cargo run")
            elseif ft == "sh" then
                vim.api.nvim_command("bash %")
            elseif ft == "tex" then
                if vim.tbl_contains(lsp.lsp_list, "texlab") then
                    vim.api.nvim_command("TexlabBuild")
                end
            end
        end
    end, { desc = "Run", silent = true })
end
