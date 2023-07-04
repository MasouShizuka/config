local variables = require("config.variables")

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
            require("session_manager").setup({
                sessions_dir = variables.data_path .. "/lazy/neovim-session-manager/sessions", -- The directory where the session files will be saved.
                path_replacer = "__",                                                          -- The character to which the path separator will be replaced for session files.
                colon_replacer = "++",                                                         -- The character to which the colon symbol will be replaced for session files.
                autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,     -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
                autosave_last_session = true,                                                  -- Automatically save last session on exit and on session switch.
                autosave_ignore_not_normal = true,                                             -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
                autosave_ignore_dirs = {},                                                     -- A list of directories where the session will not be autosaved.
                autosave_ignore_filetypes = {                                                  -- All buffers of these file types will be closed before the session is saved.
                    "gitcommit",
                },
                autosave_ignore_buftypes = {},   -- All buffers of these bufer types will be closed before the session is saved.
                autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
                max_path_length = 80,            -- Shorten the display path if length exceeds this threshold. Use 0 if don"t want to shorten the path at all.
            })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        enabled = not variables.is_vscode,
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.register({
                    mode = "n",
                    ["<leader>s"] = {
                        name = "+neovim-session-manager",
                    },
                })
            end
        end,
        keys = {
            { "<leader>sl", function(...) require("session_manager").load_session(...) end,      desc = "Load session",      mode = "n" },
            { "<leader>sp", function(...) require("session_manager").load_last_session(...) end, desc = "Load last session", mode = "n" },
            {
                "<leader>ss",
                function(...)
                    require("session_manager").save_current_session(...)
                    vim.notify("Session Saved!", vim.log.levels.INFO, { title = "neovim-session-manager" })
                end,
                desc = "Save current sessoin",
                mode = "n",
            },
            { "<leader>sd", function(...) require("session_manager").delete_session(...) end, desc = "Delete session", mode = "n" },
        },
        event = {
            "VimEnter",
        },
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
    --             if variables.is_windows then
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
    --     enabled = not variables.is_vscode,
    --     init = function()
    --         vim.g.path_replacer = "__"
    --         vim.g.colon_replacer = "++"
    --
    --         local ok, wk = pcall(require, "which-key")
    --         if ok then
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
    --     lazy = false,
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
