local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

return {
    {
        "Shatur/neovim-session-manager",
        cmd = {
            "SessionManager",
        },
        config = function(_, opts)
            require("session_manager").setup(opts)

            -- 标记 session 读取的 buf
            vim.api.nvim_create_autocmd("User", {
                callback = function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_valid(buf) then
                            vim.b[buf].session_file = true
                        end
                    end
                end,
                group = vim.api.nvim_create_augroup("SessionManagerFile", { clear = true }),
                pattern = "SessionLoadPost",
            })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        enabled = not environment.is_vscode,
        init = function()
            if utils.is_available("which-key.nvim") then
                require("which-key").add({
                    { "<leader>s", group = "neovim-session-manager", mode = "n" },
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
            local Path = require("plenary.path")

            local sessions_dir = path.data_path .. "/lazy/neovim-session-manager/sessions"
            if environment.is_wsl then
                sessions_dir = path.wsl_data_path .. "/lazy/neovim-session-manager/sessions_wsl"
            end
            if vim.fn.isdirectory(sessions_dir) == 0 then
                vim.fn.mkdir(sessions_dir)
            end

            -- 选择 gsub 中不会转义的字符，否则需要添加 % 来防止转义
            local path_replacer = "__"
            local colon_replacer = "=="

            return {
                sessions_dir = sessions_dir, -- The directory where the session files will be saved.
                -- Function that replaces symbols into separators and colons to transform filename into a session directory.
                session_filename_to_dir = function(filename)
                    local dir = filename:sub(#tostring(sessions_dir) + 2)
                    dir = dir:gsub(colon_replacer, ":")
                    dir = dir:gsub(path_replacer, Path.path.sep)
                    return Path:new(dir)
                end,
                -- Function that replaces separators and colons into special symbols to transform session directory into a filename. Should use `vim.loop.cwd()` if the passed `dir` is `nil`.
                dir_to_session_filename = function(dir)
                    local filename = dir:gsub(":", colon_replacer)
                    filename = filename:gsub(Path.path.sep, path_replacer)
                    return Path:new(sessions_dir):joinpath(filename)
                end,
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
}