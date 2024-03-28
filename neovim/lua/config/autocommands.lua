local environment = require("utils.environment")
local filetype = require("utils.filetype")
local lsp = require("utils.lsp")
local path = require("utils.path")
local treesitter = require("utils.treesitter")
local utils = require("utils")

-- 检测到对应类型的文件时发出 event
vim.api.nvim_create_autocmd("Filetype", {
    callback = function(args)
        utils.event("TreesitterFile")
        if not environment.is_vscode then
            utils.refresh_buf(args.buf, 1, true)
        end
        vim.api.nvim_del_augroup_by_name("TreesitterFile")
    end,
    desc = "Treesitter file event",
    group = vim.api.nvim_create_augroup("TreesitterFile", { clear = true }),
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
        callback = function(args)
            utils.event("LspFile")
            utils.refresh_buf(args.buf, 1, true)
            vim.api.nvim_del_augroup_by_name("LspFile")
        end,
        desc = "Lsp file event",
        group = vim.api.nvim_create_augroup("LspFile", { clear = true }),
        pattern = lsp.lsp_filetype_list,
    })
end

-- 自动保存 macro 到本地文件，并自动读取
local macro_file = path.data_path .. "/macro.json"
vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        local data = utils.json_load(macro_file)
        data[vim.fn.reg_recording()] = vim.v.event["regcontents"]
        utils.json_save(macro_file, data)
    end,
    desc = "Save macro to local file",
    group = vim.api.nvim_create_augroup("MacroAutoSave", { clear = true }),
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    callback = function()
        local data = utils.json_load(macro_file)
        for key, value in pairs(data) do
            vim.fn.setreg(key, value)
        end
        vim.api.nvim_del_augroup_by_name("MacroAutoLoad")
    end,
    desc = "Load macro from local file",
    group = vim.api.nvim_create_augroup("MacroAutoLoad", { clear = true }),
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

    -- 当关闭最后一个主编辑区域的 buf 时，自动关闭 sidebar
    local auto_closed_sidebars = {}
    vim.api.nvim_create_autocmd("QuitPre", {
        callback = function(args)
            local buf = args.buf
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if filetype.is_in_toggle_filetype_list(ft) then
                return
            end

            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                return
            end

            local sidebars = {}
            local floating_wins = {}
            local wins = vim.api.nvim_tabpage_list_wins(0)

            for _, win in ipairs(wins) do
                if not vim.api.nvim_win_is_valid(win) then
                    goto continue
                end

                buf = vim.api.nvim_win_get_buf(win)
                ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                local is_toggle_filetype, func = filetype.is_toggle_filetype(ft)
                if is_toggle_filetype then
                    sidebars[#sidebars + 1] = {
                        win = win,
                        func = func,
                    }
                end

                if vim.api.nvim_win_get_config(win).relative ~= "" then
                    floating_wins[#floating_wins + 1] = win
                end

                ::continue::
            end

            if #wins - #floating_wins - #sidebars == 1 then
                for _, sidebar in ipairs(sidebars) do
                    local close_func = sidebar.func.close
                    if type(close_func) == "function" then
                        close_func()
                    else
                        vim.api.nvim_win_close(sidebar.win, true)
                    end
                end

                utils.clear(auto_closed_sidebars)
                auto_closed_sidebars = sidebars
            end
        end,
        desc = "Auto close sidebar",
        group = vim.api.nvim_create_augroup("SidebarAutoClose", { clear = true }),
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
    local prev_tabpage_count = vim.fn.tabpagenr("$")
    local prev_tabpage = vim.fn.tabpagenr()
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local tabpage_count = vim.fn.tabpagenr("$")
            local tabpage = vim.fn.tabpagenr()
            if tabpage > 1 and prev_tabpage ~= prev_tabpage_count and tabpage_count < prev_tabpage_count then
                vim.cmd.tabprevious()
            end
            prev_tabpage_count = tabpage_count
            prev_tabpage = vim.fn.tabpagenr()
        end,
        desc = "Go to left tab after closing tab",
        group = vim.api.nvim_create_augroup("GoToLeftTab", { clear = true }),
    })

    -- 跨 tab 同步侧边栏的打开状态
    local opened_sidebars = {}
    local synchronize_sidebar_status_across_tabs = vim.api.nvim_create_augroup("SynchronizeSidebarStatusAcrossTabs", { clear = true })
    vim.api.nvim_create_autocmd("TabLeave", {
        callback = function()
            local is_opening_tab = vim.g.is_opening_tab or false
            if is_opening_tab then
                return
            end

            if #auto_closed_sidebars > 0 then
                return
            end

            utils.clear(opened_sidebars)

            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if not vim.api.nvim_win_is_valid(win) then
                    goto continue
                end

                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                local is_toggle_filetype, func = filetype.is_toggle_filetype(ft)
                if is_toggle_filetype then
                    local close_func = func.close
                    if type(close_func) == "function" then
                        close_func()
                    else
                        vim.api.nvim_win_close(win, true)
                    end

                    opened_sidebars[#opened_sidebars + 1] = {
                        win = win,
                        func = func,
                    }
                end

                ::continue::
            end
        end,
        desc = "Remember sidebar status",
        group = synchronize_sidebar_status_across_tabs,
    })
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            local is_opening_tab = vim.g.is_opening_tab or false
            if is_opening_tab then
                return
            end

            local function reopen(sidebars)
                local is_opened = false

                for _, sidebar in ipairs(sidebars) do
                    local open_func = sidebar.func.open
                    if type(open_func) == "function" then
                        vim.schedule(function() open_func() end)
                        is_opened = true
                    end
                end

                utils.clear(sidebars)

                return is_opened
            end

            local is_opened
            if #auto_closed_sidebars > 0 then
                is_opened = reopen(auto_closed_sidebars)
            else
                is_opened = reopen(opened_sidebars)
            end

            if is_opened then
                utils.defer(function() filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1) end, 100, false)
            end
        end,
        desc = "Restore sidebar status",
        group = synchronize_sidebar_status_across_tabs,
    })
end
