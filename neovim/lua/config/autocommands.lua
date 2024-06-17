local buftype = require("utils.buftype")
local environment = require("utils.environment")
local filetype = require("utils.filetype")
local lsp = require("utils.lsp")
local path = require("utils.path")
local treesitter = require("utils.treesitter")
local utils = require("utils")

local M = {}

function M.setup()
    -- 检测到对应类型的文件时发出 event
    vim.api.nvim_create_autocmd("Filetype", {
        callback = function(args)
            utils.event("TreesitterFile", true)
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
                    utils.event("GitFile", true)
                    vim.api.nvim_del_augroup_by_name("GitFile")
                end
            end,
            desc = "Git file event",
            group = vim.api.nvim_create_augroup("GitFile", { clear = true }),
        })
        vim.api.nvim_create_autocmd("Filetype", {
            callback = function(args)
                utils.event("LspFile", true)
                utils.refresh_buf(args.buf, 1, true)
                vim.api.nvim_del_augroup_by_name("LspFile")
            end,
            desc = "Lsp file event",
            group = vim.api.nvim_create_augroup("LspFile", { clear = true }),
            pattern = lsp.lsp_filetype_list,
        })
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
            pattern = utils.table_concat(filetype.tex_filetype_list, filetype.text_filetype_list),
        })

        -- 当关闭最后一个主编辑区域的 buf 时，自动关闭 panel
        local auto_closed_panels = {}
        vim.api.nvim_create_autocmd("QuitPre", {
            callback = function(args)
                local buf = args.buf
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if filetype.is_panel_filetype(ft) then
                    return
                end

                local win = vim.api.nvim_get_current_win()
                if vim.api.nvim_win_get_config(win).relative ~= "" then
                    return
                end

                local panels = {}
                local floating_wins = {}
                local wins = vim.api.nvim_tabpage_list_wins(0)

                for _, win in ipairs(wins) do
                    if not vim.api.nvim_win_is_valid(win) then
                        goto continue
                    end

                    buf = vim.api.nvim_win_get_buf(win)
                    ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    local is_panel_filetype, func = filetype.get_panel_filetype_func(ft)
                    if is_panel_filetype then
                        panels[#panels + 1] = {
                            win = win,
                            func = func,
                        }
                    end

                    if vim.api.nvim_win_get_config(win).relative ~= "" then
                        floating_wins[#floating_wins + 1] = win
                    end

                    ::continue::
                end

                if #wins - #floating_wins - #panels == 1 then
                    for _, panel in ipairs(panels) do
                        local close_func = panel.func.close
                        if type(close_func) == "function" then
                            close_func()
                        else
                            vim.api.nvim_win_close(panel.win, true)
                        end
                    end

                    utils.table_clear(auto_closed_panels)
                    auto_closed_panels = panels
                end
            end,
            desc = "Auto close panel",
            group = vim.api.nvim_create_augroup("PanelAutoClose", { clear = true }),
        })

        -- 录制 macro 时显示信息
        if not utils.is_available("heirline.nvim") then
            local show_recording = vim.api.nvim_create_augroup("ShowRecording", { clear = true })
            vim.api.nvim_create_autocmd("RecordingEnter", {
                callback = function()
                    vim.api.nvim_set_option_value("cmdheight", 1, { scope = "local" })
                end,
                desc = "Set cmdheight=1 when start recording",
                group = show_recording,
            })
            vim.api.nvim_create_autocmd("RecordingLeave", {
                callback = function()
                    vim.api.nvim_set_option_value("cmdheight", 0, { scope = "local" })
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

        -- 跨 tab 同步 panel 的打开状态
        local opened_panels = {}
        local synchronize_panel_status_across_tabs = vim.api.nvim_create_augroup("SynchronizePanelStatusAcrossTabs", { clear = true })
        vim.api.nvim_create_autocmd("TabLeave", {
            callback = function()
                local is_opening_tab = vim.g.is_opening_tab or false
                if is_opening_tab then
                    return
                end

                if #auto_closed_panels > 0 then
                    return
                end

                utils.table_clear(opened_panels)

                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    if not vim.api.nvim_win_is_valid(win) then
                        goto continue
                    end

                    local buf = vim.api.nvim_win_get_buf(win)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                    local is_panel_filetype, func = filetype.get_panel_filetype_func(ft)
                    if is_panel_filetype then
                        local close_func = func.close
                        if type(close_func) == "function" then
                            close_func()
                        else
                            vim.api.nvim_win_close(win, true)
                        end

                        opened_panels[#opened_panels + 1] = {
                            win = win,
                            func = func,
                        }
                    end

                    ::continue::
                end
            end,
            desc = "Remember panel status",
            group = synchronize_panel_status_across_tabs,
        })
        vim.api.nvim_create_autocmd("TabEnter", {
            callback = function()
                local is_opening_tab = vim.g.is_opening_tab or false
                if is_opening_tab then
                    return
                end

                local function reopen(panels)
                    local is_opened = false

                    for _, panel in ipairs(panels) do
                        local open_func = panel.func.open
                        if type(open_func) == "function" then
                            -- vim.schedule(function() open_func() end)
                            open_func()
                            is_opened = true
                        end
                    end

                    utils.table_clear(panels)

                    return is_opened
                end

                local is_opened
                if #auto_closed_panels > 0 then
                    is_opened = reopen(auto_closed_panels)
                else
                    is_opened = reopen(opened_panels)
                end

                if is_opened then
                    utils.defer(function() filetype.skip_filetype(filetype.skip_filetype_list_to_main, -1) end, 100, false)
                end
            end,
            desc = "Restore panel status",
            group = synchronize_panel_status_across_tabs,
        })
    end
end

return M
