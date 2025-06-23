local M = {}

---@class create_event_opts
---@field condition? fun(args:vim.api.keyset.create_autocmd.callback_args):boolean
---@field desc? string
---@field event_name? string
---@field func? fun(args:vim.api.keyset.create_autocmd.callback_args)
---@field once? boolean

---@param opts create_event_opts
local function create_event(opts)
    local condition = opts.condition or function(args) return true end
    local desc = opts.desc or ""
    local event_name = opts.event_name
    local func = opts.func or function(args) end
    local once = opts.once or false

    local args = { buf = vim.api.nvim_get_current_buf() }
    if condition(args) then
        if event_name then
            vim.api.nvim_exec_autocmds("User", { pattern = event_name })
        end
        func(args)

        if once then
            return
        end
    end

    local id
    id = vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
        callback = function(args)
            if condition(args) then
                if event_name then
                    vim.api.nvim_exec_autocmds("User", { pattern = event_name })
                end
                func(args)

                if once then
                    vim.api.nvim_del_autocmd(id)
                end
            end
        end,
        desc = desc,
    })
end

M.setup = function(opts)
    local refresh_buf = function(args)
        require("utils").refresh_buf(args.buf, { timeout = 2000, use_timer = true })
    end

    -- 检测 git 仓库
    create_event({
        condition = function(args)
            return require("utils").is_git()
        end,
        desc = "Git file event",
        event_name = "GitFile",
        once = true,
    })

    -- 检测 lsp 文件
    create_event({
        condition = function(args)
            return vim.tbl_contains(require("utils.lsp").lsp_filetype_list, vim.bo[args.buf].filetype)
        end,
        desc = "Lsp file event",
        event_name = "LspFile",
        func = refresh_buf,
        once = true,
    })

    -- 检测 lint 文件
    create_event({
        condition = function(args)
            return vim.tbl_contains(require("utils.lint").lint_filetype_list, vim.bo[args.buf].filetype)
        end,
        desc = "Lint file event",
        event_name = "LintFile",
        func = refresh_buf,
        once = true,
    })

    -- 检测 treesitter 文件
    create_event({
        condition = function(args)
            return vim.tbl_contains(require("utils.treesitter").treesitter_filetype_list, vim.bo[args.buf].filetype)
        end,
        desc = "Treesitter file event",
        event_name = "TreesitterFile",
        func = refresh_buf,
        once = true,
    })

    -- 检测内嵌以外的 markdown
    create_event({
        condition = function(args)
            local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
            return vim.bo[args.buf].filetype == "markdown" and not vim.tbl_contains(require("utils.buftype").skip_buftype_list, bt)
        end,
        desc = "Markdown file event",
        event_name = "MarkdownFile",
        func = refresh_buf,
        once = true,
    })

    -- lsp 文件切换部分设置
    create_event({
        condition = function(args)
            local session_file = vim.b[args.buf].session_file or false
            return not session_file and vim.tbl_contains(require("utils.lsp").lsp_filetype_list, vim.bo[args.buf].filetype)
        end,
        desc = "Change settings for lsp file",
        func = function(args)
            vim.api.nvim_set_option_value("signcolumn", "yes", { scope = "local" })
        end,
    })

    -- 文本文件切换部分设置
    create_event({
        condition = function(args)
            local filetype = require("utils.filetype")
            local filetype_list = require("utils").table_concat(filetype.tex_filetype_list, filetype.text_filetype_list)
            local session_file = vim.b[args.buf].session_file or false
            return not session_file and vim.tbl_contains(filetype_list, vim.bo[args.buf].filetype)
        end,
        desc = "Change settings for text file",
        func = function(args)
            vim.api.nvim_set_option_value("spell", true, { scope = "local" })
            vim.api.nvim_set_option_value("wrap", true, { scope = "local" })
        end,
    })

    -- 打开 help 时移动到右边
    -- https://github.com/anuvyklack/help-vsplit.nvim
    vim.api.nvim_create_autocmd({ "BufEnter", "WinNew" }, {
        callback = function(args)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
            if ft ~= "help" then
                return
            end

            local origin_win = vim.fn.win_getid(vim.fn.winnr("#"))

            local help_buf = vim.api.nvim_get_current_buf()

            local bufhidden = vim.api.nvim_get_option_value("bufhidden", { buf = args.buf })
            vim.api.nvim_set_option_value("bufhidden", "hide", { buf = args.buf })

            local old_help_win = vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(origin_win)

            vim.api.nvim_win_close(old_help_win, false)

            vim.api.nvim_command("vsplit")
            vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), help_buf)
            vim.api.nvim_set_option_value("bufhidden", bufhidden, { buf = args.buf })
        end,
        desc = "Open help in a vertical split",
        group = vim.api.nvim_create_augroup("HelpVerticalSplit", { clear = true }),
    })

    -- https://github.com/stevearc/dotfiles/blob/6bc8a8c96af72ab5b0437865542db3ad5d57ba0f/.config/nvim/init.lua#L286-L297
    local checktime = vim.api.nvim_create_augroup("Checktime", { clear = true })
    vim.api.nvim_create_autocmd("FocusGained", {
        callback = function(args)
            if vim.fn.getcmdwintype() == "" then
                vim.api.nvim_command("checktime " .. args.buf)
            end
        end,
        desc = "Reload files from disk when we focus vim",
        group = checktime,
    })
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(args)
            local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
            if bt ~= "" then
                return
            end

            local is_modified = vim.api.nvim_get_option_value("modified", { buf = args.buf })
            if is_modified then
                return
            end

            vim.api.nvim_command("checktime " .. args.buf)
        end,
        desc = "Every time we enter an unmodified buffer, check if it changed on disk",
        group = checktime,
    })
end

return M
