local environment = require("utils.environment")
local filetype = require("utils.filetype")
local lsp = require("utils.lsp")
local path = require("utils.path")
local treesitter = require("utils.treesitter")
local utils = require("utils")

-- 检测到对应类型的文件时发出 event
vim.api.nvim_create_autocmd("Filetype", {
    callback = function()
        utils.event("TreesitterFile")
        if not environment.is_vscode then
            utils.refresh_current_buf(1000, true)
        end
    end,
    desc = "Treesitter file event",
    group = vim.api.nvim_create_augroup("TreesitterFile", { clear = true }),
    once = true,
    pattern = treesitter.treesitter_filetype_list,
})
if not environment.is_vscode then
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
        callback = function()
            if utils.is_git() then
                utils.event("GitFile")
                vim.api.nvim_del_augroup_by_name("GitFile")
            end
        end,
        desc = "Git file event",
        group = vim.api.nvim_create_augroup("GitFile", { clear = true }),
    })
    vim.api.nvim_create_autocmd("Filetype", {
        callback = function()
            utils.event("LspFile")
            utils.refresh_current_buf(1000, true)
        end,
        desc = "Lsp file event",
        group = vim.api.nvim_create_augroup("LspFile", { clear = true }),
        once = true,
        pattern = lsp.lsp_filetype_list,
    })
end

-- 自动保存 macro 到本地文件，并自动读取
local macro_auto_save_load = vim.api.nvim_create_augroup("MacroAutoSaveLoad", { clear = true })
local macro_file = path.data_path .. "/macro.json"
vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        local data = utils.json_load(macro_file)
        data[vim.fn.reg_recording()] = vim.v.event["regcontents"]
        utils.json_save(macro_file, data)
    end,
    desc = "Save macro to local file",
    group = macro_auto_save_load,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    callback = function()
        local data = utils.json_load(macro_file)
        for key, value in pairs(data) do
            vim.fn.setreg(key, value)
        end
    end,
    desc = "Load macro from local file",
    group = macro_auto_save_load,
    once = true,
})

if not environment.is_vscode then
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
        pattern = filetype.text_filetype,
    })

    -- 录制 macro 时显示信息
    if not utils.is_available("heirline.nvim") then
        local show_recording = vim.api.nvim_create_augroup("ShowRecording", { clear = true })
        vim.api.nvim_create_autocmd("RecordingEnter", {
            callback = function()
                vim.api.nvim_set_option_value("cmdheight", 1, {})
            end,
            desc = "Set cmdheight=1 when start recording",
            group = show_recording,
        })
        vim.api.nvim_create_autocmd("RecordingLeave", {
            callback = function()
                vim.api.nvim_set_option_value("cmdheight", 0, {})
            end,
            desc = "Set cmdheight=0 when finished recording",
            group = show_recording,
        })
    end

    -- 关闭 tab 后转到左边的 tab
    local prev_last_tabpage = vim.fn.tabpagenr("$")
    local prev_tabpage = vim.fn.tabpagenr()
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local last_tabpage = vim.fn.tabpagenr("$")
            local tabpage = vim.fn.tabpagenr()
            if tabpage > 1 and prev_tabpage ~= prev_last_tabpage and last_tabpage < prev_last_tabpage then
                vim.cmd.tabprevious()
            end
            prev_last_tabpage = last_tabpage
            prev_tabpage = tabpage
        end,
        desc = "Go to left tab after closing tab",
        group = vim.api.nvim_create_augroup("GoToLeftTab", { clear = true }),
    })
end
