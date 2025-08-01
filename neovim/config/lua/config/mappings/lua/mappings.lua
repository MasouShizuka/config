local M = {}

function M.setup(opts)
    local environment = require("utils.environment")
    local filetype = require("utils.filetype")
    local keymap = require("utils.keymap")
    local lsp = require("utils.lsp")
    local utils = require("utils")

    -- 清除原有 keymap
    if utils.is_available("which-key.nvim") then
        local wk = require("which-key")
        vim.keymap.set("n", "s", function() wk.show({ mode = "n", keys = "s" }) end, { desc = "Show s keymaps" })
        vim.keymap.set("x", "s", function() wk.show({ mode = "x", keys = "s" }) end, { desc = "Show s keymaps" })
    else
        vim.keymap.set({ "n", "x" }, "<space>", "<nop>", { silent = true })
        vim.keymap.set({ "n", "x" }, "s", "<nop>", { silent = true })
    end
    pcall(vim.keymap.del, "n", "grn")
    pcall(vim.keymap.del, { "n", "x" }, "gra")
    pcall(vim.keymap.del, "n", "grr")
    pcall(vim.keymap.del, "n", "gri")
    pcall(vim.keymap.del, "n", "grt")

    -- 复制到 clipboard
    vim.keymap.set({ "n", "x" }, "C", '"+c', { silent = true })
    vim.keymap.set({ "n", "x" }, "D", '"+d', { silent = true })
    vim.keymap.set({ "n", "x" }, "X", '"+x', { silent = true })
    if not utils.is_available("yanky.nvim") then
        vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { silent = true })
        vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { silent = true })
        vim.keymap.set({ "n", "x" }, "Y", '"+y', { silent = true })
    end
    vim.keymap.set({ "n", "x" }, "YY", "Yy", { remap = true, silent = true })

    -- 跳到行首行尾不带空格
    vim.keymap.set({ "n", "x", "o" }, "H", "^", { desc = "Start of line (non-blank)", silent = true })
    vim.keymap.set({ "n", "x", "o" }, "L", "g_", { desc = "End of line (non-blank)", silent = true })

    -- 折行时小步上下移动
    local function move(key, set_jumps)
        set_jumps = set_jumps == nil or set_jumps

        local prefix = ""

        local count = vim.v.count
        if count > 0 then
            prefix = prefix .. tostring(count)
            if set_jumps then
                vim.cmd.normal({ "m'", bang = true })
            end
        end

        if count == 0 and not vim.fn.mode():find("V") then
            if environment.is_vscode then
                vim.cmd.normal({ string.format("g%s", key) })
            else
                vim.cmd.normal({ string.format("g%s", key), bang = true })
            end
        else
            vim.cmd.normal({ string.format("%s%s", prefix, key), bang = true })
        end

        local buf = vim.api.nvim_get_current_buf()
        local cursor_center_enabled
        if vim.b[buf].cursor_center == nil then
            cursor_center_enabled = vim.g.cursor_center
        else
            cursor_center_enabled = vim.b[buf].cursor_center
        end

        if cursor_center_enabled then
            if environment.is_vscode then
                vim.cmd.normal("zz")
            else
                vim.cmd.normal({ "zz", bang = true })
            end
        end
    end
    vim.keymap.set({ "n", "x" }, "j", function() move("j") end, { desc = "Down", silent = true })
    vim.keymap.set({ "n", "x" }, "k", function() move("k") end, { desc = "Up", silent = true })

    -- 上下移动选中文本
    vim.keymap.set("x", "J", ":move '>+1<cr>gv-gv", { desc = "Move selected text up", silent = true })
    vim.keymap.set("x", "K", ":move '<-2<cr>gv-gv", { desc = "Move selected text down", silent = true })

    -- mark
    vim.keymap.set("n", "M", "m", { desc = "Mark", silent = true })

    -- 跳转居中
    vim.keymap.set({ "n", "x" }, "n", "nzz", { desc = "Jump to next location", remap = true, silent = true })
    vim.keymap.set({ "n", "x" }, "N", "Nzz", { desc = "Jump to next location", remap = true, silent = true })

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
        -- https://github.com/niuiic/scroll.nvim
        local scroll_count = 0
        ---@param target_line number
        ---@param step fun(current_line: number, target_line: number) {next_line: number, delay: number, target_line: number | nil}
        local scroll = function(target_line, step)
            scroll_count = scroll_count + 1
            local current_count = scroll_count
            local line_count = vim.api.nvim_buf_line_count(0)
            local start_line = vim.api.nvim_win_get_cursor(0)[1]
            local column = vim.api.nvim_win_get_cursor(0)[2]
            local end_line
            local scroll_direction
            local current_line = start_line

            local make_config = function()
                if target_line > line_count then
                    end_line = line_count
                elseif target_line < 1 then
                    end_line = 1
                else
                    end_line = math.floor(target_line)
                end
                if start_line < end_line then
                    scroll_direction = "down"
                else
                    scroll_direction = "up"
                end
            end
            make_config()

            local scroll_step
            scroll_step = function()
                if scroll_count ~= current_count then
                    return
                end

                if scroll_direction == "down" and current_line >= end_line then
                    return
                end

                if scroll_direction == "up" and current_line <= end_line then
                    return
                end

                local cur_step = step(current_line, target_line)
                if cur_step.target_line ~= nil then
                    target_line = cur_step.target_line
                    make_config()
                end
                local next_line
                if scroll_direction == "down" and cur_step.next_line > end_line then
                    next_line = end_line
                elseif scroll_direction == "up" and cur_step.next_line < end_line then
                    next_line = end_line
                else
                    next_line = math.floor(cur_step.next_line)
                end

                if next_line == current_line then
                    vim.notify("Next line is equal to current line, scroll exits, check your config", vim.log.levels.WARN, {
                        title = "scroll.nvim",
                    })
                    return
                end

                local ok = pcall(vim.api.nvim_win_set_cursor, 0, { next_line, column })
                if not ok then
                    return
                end
                current_line = next_line
                vim.defer_fn(scroll_step, cur_step.delay)
            end

            scroll_step()
        end
        vim.keymap.set({ "n", "x" }, "<c-d>", function()
            local screen_h = vim.api.nvim_get_option_value("scroll", { scope = "local" }) * 2
            local target_lnum = vim.api.nvim_win_get_cursor(0)[1] + screen_h / 2
            local step = screen_h / 2 / 50
            if step < 1 then
                step = 1
            end

            scroll(target_lnum, function(current_line, target_line)
                local fold_end = vim.fn.foldclosedend(current_line)

                -- if current_line is not in a fold
                if fold_end < 0 then
                    return {
                        -- cursor position in next step
                        next_line = current_line + step,
                        -- delay 10ms for next step
                        delay = 10,
                    }
                end

                local fold_start = vim.fn.foldclosed(current_line)

                return {
                    next_line = fold_end + 1,
                    delay = 10,
                    -- when current_line is in a fold, you may want to regard it as one line, then you need to change the target_line
                    target_line = target_line + fold_end - fold_start,
                }
            end)
        end, { silent = true })
        vim.keymap.set({ "n", "x" }, "<c-u>", function()
            local screen_h = vim.api.nvim_get_option_value("scroll", { scope = "local" }) * 2
            local target_lnum = vim.api.nvim_win_get_cursor(0)[1] - screen_h / 2
            local step = screen_h / 2 / 50
            if step < 1 then
                step = 1
            end

            scroll(target_lnum, function(current_line, target_line)
                local fold_end = vim.fn.foldclosedend(current_line)
                if fold_end > 0 then
                    local fold_start = vim.fn.foldclosed(current_line)

                    return {
                        next_line = fold_start - 1,
                        delay = 10,
                        target_line = target_line - fold_end + fold_start,
                    }
                end

                return {
                    next_line = current_line - step,
                    delay = 10,
                }
            end)
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
        if not utils.is_available("nvim-cmp") and not utils.is_available("blink.cmp") then
            vim.keymap.set("c", "<down>", "<c-n>", { desc = "Down", silent = true })
            vim.keymap.set("c", "<up>", "<c-p>", { desc = "Up", silent = true })
            vim.keymap.set("c", "<c-j>", "<c-n>", { desc = "Down", silent = true })
            vim.keymap.set("c", "<c-k>", "<c-p>", { desc = "Up", silent = true })
        end

        -- 折行时小步上下移动
        vim.keymap.set("i", "<down>", function() vim.cmd.normal({ "gj", bang = true }) end, { desc = "Down", silent = true })
        vim.keymap.set("i", "<up>", function() vim.cmd.normal({ "gk", bang = true }) end, { desc = "Up", silent = true })

        -- 终端
        vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], { desc = "Enter normal mode", silent = true })
        vim.keymap.set("t", "<c-s-v>", '<C-\\><C-N>"+pi', { desc = "Paste", silent = true })

        if not utils.is_available("edgy.nvim") then
            -- 聚焦 left panel
            vim.keymap.set("n", keymap["<c-1>"], function() filetype.toggle_panel("left") end, { desc = "Focus left panel", silent = true })
            -- 聚焦主编辑区域
            vim.keymap.set("n", keymap["<c-2>"], function() filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1) end, { desc = "Focus editor", silent = true })
            -- 聚焦 bottom panel
            vim.keymap.set("n", keymap["<c-3>"], function()
                local count = vim.v.count
                if count > 0 then
                    if utils.is_available("snacks.nvim") then
                        filetype.bottom_panel_filetype_list["snacks_terminal"].open()
                        return
                    end
                end

                filetype.toggle_panel("bottom")
            end, { desc = "Focus bottom panel", silent = true })
            -- 聚焦 right panel
            vim.keymap.set("n", keymap["<c-4>"], function() filetype.toggle_panel("right") end, { desc = "Focus right panel", silent = true })
        end

        -- 跳转居中
        if not utils.is_available("neoscroll.nvim") then
            vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "Scroll half page down", silent = true })
            vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "Scroll half page up", silent = true })
        end
        vim.keymap.set("n", "<c-i>", "<c-i>zz", { desc = "Jump to next location", silent = true })
        vim.keymap.set("n", "<c-o>", "<c-o>zz", { desc = "Jump to previous location", silent = true })

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

        -- 搜索并替换
        vim.keymap.set("n", "<c-f>", function()
            if utils.is_available("config.autocommands.hlsearch") and not package.loaded["hlsearch"] then
                require("lazy").load({ plugins = "config.autocommands.hlsearch" })
            end
            return ":1,$s///gcI<left><left><left><left><left>"
        end, { desc = "Search and replace in file", expr = true })
        vim.keymap.set("x", "<c-f>", function()
            if utils.is_available("config.autocommands.hlsearch") and not package.loaded["hlsearch"] then
                require("lazy").load({ plugins = "config.autocommands.hlsearch" })
            end
            return ":s///gcI<left><left><left><left><left>"
        end, { desc = "Search and replace in file", expr = true })

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
        vim.keymap.set("n", "<c-t>", function() vim.api.nvim_command("tab sbuffer") end, { desc = "Copy tab", silent = true })
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

        -- diff
        vim.keymap.set("n", "<c-n>", function()
            vim.cmd.normal({ "]c", bang = true })
            vim.cmd.normal({ "zz", bang = true })
        end, { desc = "Next diff", silent = true })
        vim.keymap.set("n", keymap["<c-s-n>"], function()
            vim.cmd.normal({ "[c", bang = true })
            vim.cmd.normal({ "zz", bang = true })
        end, { desc = "Previous diff", silent = true })

        -- 退出
        vim.keymap.set({ "n", "x" }, "<c-w>", function()
            if utils.is_available("config.autocommands.panel-synchronize") then
                if not package.loaded["panel-synchronize"] then
                    require("lazy").load({ plugins = "config.autocommands.panel-synchronize" })
                end
                require("panel-synchronize").close()
            else
                vim.cmd.quit()
            end
        end, { desc = "Quit", nowait = true, silent = true })
        vim.keymap.set({ "n", "x" }, "<leader><c-w>", function() vim.cmd.quitall({ bang = true }) end, { desc = "Quit all", nowait = true, silent = true })

        -- 运行
        if not utils.is_available("overseer.nvim") then
            vim.keymap.set("n", "<leader>r", function()
                local curr_file = vim.fn.expand("%:p:.")
                local curr_file_no_ext = vim.fn.fnamemodify(curr_file, ":r")
                local output = curr_file_no_ext
                if environment.is_windows then
                    curr_file = curr_file:gsub("\\", "/")
                    output = output:gsub("\\", "/") .. ".exe"
                end

                local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
                if ft == "cpp" then
                    -- 若在使用 vector 等库时编译的程序无法运行，可能需要在编译时添加 -static-libstdc++
                    -- https://stackoverflow.com/questions/6404636/libstdc-6-dll-not-found/6405064#6405064
                    local command = string.format([[clang++ -static-libstdc++ "%s" -o "%s" && ./"%s" && rm ./"%s"]], curr_file, output, output, output)
                    vim.api.nvim_command(command)
                elseif ft == "lua" then
                    local command = string.format([[luafile "%s"]], curr_file)
                    vim.api.nvim_command(command)
                elseif ft == "markdown" then
                    if utils.is_available("markdown-preview.nvim") then
                        vim.api.nvim_command("MarkdownPreviewToggle")
                    end
                elseif ft == "python" then
                    local command = string.format([[python -u "%s"]], curr_file)
                    vim.api.nvim_command(command)
                elseif ft == "rust" then
                    local command = "cargo run"
                    vim.api.nvim_command(command)
                elseif ft == "sh" then
                    local command = string.format([[sh "%s"]], curr_file)
                    vim.api.nvim_command(command)
                elseif ft == "tex" then
                    if vim.tbl_contains(lsp.lsp_list, "texlab") then
                        vim.api.nvim_command("TexlabBuild")
                    end
                end
            end, { desc = "Run", silent = true })
        end
    end
end

return M
