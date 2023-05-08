local variables = require("variables")

return {
    "Shatur/neovim-session-manager",
    cond = not variables.is_vscode,
    config = function(_, opts)
        require("session_manager").setup({
            sessions_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/lazy/neovim-session-manager/sessions/"), -- The directory where the session files will be saved.
            path_replacer = "__",                                                                             -- The character to which the path separator will be replaced for session files.
            colon_replacer = "++",                                                                            -- The character to which the colon symbol will be replaced for session files.
            autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,                        -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
            autosave_last_session = true,                                                                     -- Automatically save last session on exit and on session switch.
            autosave_ignore_not_normal = true,                                                                -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
            autosave_ignore_dirs = {},                                                                        -- A list of directories where the session will not be autosaved.
            autosave_ignore_filetypes = {                                                                     -- All buffers of these file types will be closed before the session is saved.
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
    keys = {
        {
            "<Leader>sl",
            function(...)
                require("session_manager").load_session(...)
            end,
            mode = "n",
        },
        {
            "<Leader>sp",
            function(...)
                require("session_manager").load_last_session(...)
            end,
            mode = "n",
        },
        {
            "<Leader>ss",
            function(...)
                require("session_manager").save_current_session(...)
                vim.notify("Session Saved!", vim.log.levels.INFO, { title = "neovim-session-manager" })
            end,
            mode = "n",
        },
        {
            "<Leader>sd",
            function(...)
                require("session_manager").delete_session(...)
            end,
            mode = "n",
        },
    },
    event = { "VimEnter" },
}
