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
}
