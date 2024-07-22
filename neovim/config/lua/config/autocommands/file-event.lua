local buftype = require("utils.buftype")
local filetype = require("utils.filetype")
local lsp = require("utils.lsp")
local utils = require("utils")

local M = {}

M.setup = function(opts)
    -- 检测 git 仓库
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
        callback = function()
            if utils.is_git() then
                utils.event("GitFile", true)
                vim.api.nvim_del_augroup_by_name("GitFile")
            end
        end,
        desc = "Git file event",
        group = vim.api.nvim_create_augroup("GitFile", { clear = true }),
    })

    -- 检测内嵌以外的 markdown
    vim.api.nvim_create_autocmd("Filetype", {
        callback = function(args)
            local bt = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
            -- 防止在 lsp hover 等内嵌 markdown 中激活 markdown plugins
            if not vim.tbl_contains(buftype.skip_buftype_list, bt) then
                utils.event("MarkdownFile", true)
                utils.refresh_buf(args.buf, 1, true)
                vim.api.nvim_del_augroup_by_name("MarkdownFile")
            end
        end,
        desc = "Markdown file event",
        group = vim.api.nvim_create_augroup("MarkdownFile", { clear = true }),
        pattern = "markdown",
    })

    -- lsp 文件切换部分设置
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            local session_file = vim.b[args.buf].session_file or false
            if not session_file then
                vim.api.nvim_set_option_value("signcolumn", "yes", { scope = "local" })
            end
        end,
        desc = "Change settings for lsp file",
        group = vim.api.nvim_create_augroup("LspSetting", { clear = true }),
        pattern = lsp.lsp_filetype_list,
    })

    -- 文本文件切换部分设置
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            local session_file = vim.b[args.buf].session_file or false
            if not session_file then
                vim.api.nvim_set_option_value("spell", true, { scope = "local" })
                vim.api.nvim_set_option_value("wrap", true, { scope = "local" })
            end
        end,
        desc = "Change settings for text file",
        group = vim.api.nvim_create_augroup("TextSetting", { clear = true }),
        pattern = utils.table_concat(filetype.tex_filetype_list, filetype.text_filetype_list),
    })
end

return M
