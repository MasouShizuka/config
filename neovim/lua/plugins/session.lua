local environment = require("utils.environment")
local lsp = require("utils.lsp")
local path = require("utils.path")
local treesitter = require("utils.treesitter")
local utils = require("utils")

return {
    {
        "Shatur/neovim-session-manager",
        cmd = {
            "SessionManager load_session",
            "SessionManager load_last_session",
            "SessionManager load_current_dir_session",
            "SessionManager save_current_session",
            "SessionManager delete_session",
        },
        config = function(_, opts)
            require("session_manager").setup(opts)

            -- 由于使用 file event 的方式激活 nvim-lspconfig 和 nvim-treesitter，需要刷新 session 中的 buffer 使得 plugins 生效
            vim.api.nvim_create_autocmd("User", {
                callback = function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_valid(buf) and buf ~= vim.api.nvim_get_current_buf() then
                            local filetype = vim.bo[buf].filetype
                            if vim.tbl_contains(lsp.lsp_filetype_list, filetype) then
                                utils.refresh_buf(buf, 1, true)
                            end
                            if vim.tbl_contains(treesitter.treesitter_filetype_list, filetype) then
                                utils.refresh_buf(buf, 1, true)
                            end
                        end
                    end
                end,
                group = vim.api.nvim_create_augroup("neovim-session-manager", { clear = true }),
                pattern = "SessionLoadPost",
            })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        enabled = not environment.is_vscode,
        init = function()
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
                    mode = "n",
                    ["<leader>s"] = {
                        name = "+neovim-session-manager",
                    },
                })
            end

            -- 判断是否启动 neovim-session-manager
            if vim.fn.argc() == 0 then
                require("session_manager")
            end
        end,
        keys = {
            { "<leader>sl", function() vim.api.nvim_command("SessionManager load_session") end,      desc = "Load session",      mode = "n" },
            { "<leader>sp", function() vim.api.nvim_command("SessionManager load_last_session") end, desc = "Load last session", mode = "n" },
            {
                "<leader>ss",
                function()
                    vim.api.nvim_command("SessionManager save_current_session")
                    vim.notify("Session saved!", vim.log.levels.INFO, { title = "neovim-session-manager" })
                end,
                desc = "Save current sessoin",
                mode = "n",
            },
            { "<leader>sd", function() vim.api.nvim_command("SessionManager delete_session") end, desc = "Delete session", mode = "n" },
        },
        opts = function()
            local sessions_dir = path.data_path .. "/lazy/neovim-session-manager/sessions"
            if environment.is_wsl then
                sessions_dir = path.wsl_data_path .. "/lazy/neovim-session-manager/sessions_wsl"
            end
            if vim.fn.isdirectory(sessions_dir) == 0 then
                vim.fn.mkdir(sessions_dir)
            end

            return {
                sessions_dir = sessions_dir,                                               -- The directory where the session files will be saved.
                autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
                autosave_last_session = true,                                              -- Automatically save last session on exit and on session switch.
                autosave_ignore_not_normal = true,                                         -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
                autosave_ignore_dirs = {},                                                 -- A list of directories where the session will not be autosaved.
                autosave_ignore_filetypes = {                                              -- All buffers of these file types will be closed before the session is saved.
                    "gitcommit",
                    "gitrebase",
                },
                autosave_ignore_buftypes = {},   -- All buffers of these bufer types will be closed before the session is saved.
                autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
                max_path_length = 80,            -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
            }
        end,
    },

    -- resession 目前还存在许多问题
    -- {
    --     "stevearc/resession.nvim",
    --     config = function(_, opts)
    --         local resession = require("resession")
    --         resession.setup(opts)
    --
    --         local function get_saved_session_name()
    --             local cwd = vim.fn.getcwd()
    --             if environment.is_windows then
    --                 cwd = cwd:gsub("\\", "/")
    --             end
    --             cwd = cwd:gsub("/", vim.g.path_replacer)
    --             cwd = cwd:gsub(":", vim.g.colon_replacer)
    --
    --             return cwd
    --         end
    --
    --         local function is_session_exist()
    --             local cwd = get_saved_session_name()
    --             local list = resession.list()
    --             for _, session in ipairs(list) do
    --                 if cwd == session then
    --                     return true, session
    --                 end
    --             end
    --             return false, nil
    --         end
    --
    --         local function delete_invisiable_buffer()
    --             local open_buffers = vim.fn.getbufinfo({ buflisted = 1 })
    --             if #open_buffers < 1 then
    --                 return
    --             end
    --
    --             for _, buf in pairs(open_buffers) do
    --                 local is_modified = vim.api.nvim_get_option_value("modified", { buf = buf.bufnr })
    --                 local is_visible = buf.hidden == 0 and buf.loaded == 1
    --                 local notification = true
    --
    --                 if not is_modified and not is_visible then
    --                     if is_modified then
    --                         vim.cmd.write()
    --                     end
    --
    --                     vim.api.nvim_buf_delete(buf.bufnr, { force = false, unload = false })
    --
    --                     if notification then
    --                         vim.notify("Auto Closed Buffer: " .. vim.fs.basename(buf.name))
    --                     end
    --                 end
    --             end
    --         end
    --
    --         vim.keymap.set("n", "<leader>ss", function()
    --             delete_invisiable_buffer()
    --             resession.save(get_saved_session_name(), { notify = true })
    --         end, { desc = "Session save", silent = true })
    --         vim.keymap.set("n", "<leader>sl", function() resession.load() end, { desc = "Session load", silent = true })
    --         vim.keymap.set("n", "<leader>sd", function() resession.delete() end, { desc = "Session delete", silent = true })
    --
    --         vim.api.nvim_create_autocmd("VimEnter", {
    --             callback = function()
    --                 local is_exist, session = is_session_exist()
    --                 if is_exist then
    --                     resession.load(session)
    --                 end
    --             end,
    --         })
    --         vim.api.nvim_create_autocmd("VimLeavePre", {
    --             callback = function()
    --                 local is_exist, session = is_session_exist()
    --                 if is_exist then
    --                     delete_invisiable_buffer()
    --                     resession.save(session)
    --                     resession.save("last")
    --                 end
    --             end,
    --         })
    --     end,
    --     enabled = not environment.is_vscode,
    --     event = {
    --         "VimEnter",
    --     },
    --     init = function()
    --         vim.g.path_replacer = "__"
    --         vim.g.colon_replacer = "++"
    --
    --         local is_which_key_available, which_key = pcall(require, "which-key")
    --         if is_which_key_available then
    --             wk.register({
    --                 mode = "n",
    --                 ["<leader>s"] = {
    --                     name = "+resession",
    --                 },
    --             })
    --         end
    --     end,
    --     keys = {
    --         { "<leader>ss", desc = "Session save",   mode = "n" },
    --         { "<leader>sl", desc = "Session load",   mode = "n" },
    --         { "<leader>sd", desc = "Session delete", mode = "n" },
    --     },
    --     opts = {
    --         options = {
    --             "binary",
    --             "bufhidden",
    --             "buflisted",
    --             "cmdheight",
    --             "diff",
    --             "filetype",
    --             "modifiable",
    --             "previewwindow",
    --             "readonly",
    --             "scrollbind",
    --             "winfixheight",
    --             "winfixwidth",
    --             "wrap",
    --         },
    --         dir = "lazy/resession.nvim/session",
    --     },
    -- },
}
