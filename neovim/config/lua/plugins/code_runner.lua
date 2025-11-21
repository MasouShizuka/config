local environment = require("utils.environment")

return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerRun",
            "OverseerShell",
            "OverseerTaskAction",
        },
        cond = not environment.is_vscode,
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>o",  group = "overseer",        mode = "n" },
                        })
                    end,
                    desc = "Register which-key for overseer",
                    pattern = "IceLoad",
                })
            end
        end,
        keys = {
            { "<leader>oo", function() vim.api.nvim_command("OverseerToggle") end,         desc = "Toggle the overseer window. With ! cursor stays in current window",                   mode = "n" },
            { "<leader>or", function() vim.api.nvim_command("OverseerRun") end,            desc = "Run a task from a template",                                                          mode = "n" },
            { "<leader>os", function() vim.api.nvim_command("OverseerShell") end,          desc = "Run a shell command as an overseer task. With ! the task is created but not started", mode = "n" },
            { "<leader>ot", function() vim.api.nvim_command("OverseerTaskAction") end,     desc = "Select a task to run an action on",                                                   mode = "n" },
            { "<leader>r",  function() require("overseer").run_task({ name = "run" }) end, desc = "Run",                                                                                 mode = "n" },
        },
        opts = {
            -- Configure the task list
            task_list = {
                -- Default direction. Can be "left", "right", or "bottom"
                direction = "right",
                -- Set keymap to false to remove default behavior
                -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
                keymaps = {
                    -- ["?"] = "keymap.show_help",
                    -- ["g?"] = "keymap.show_help",
                    -- ["<CR>"] = "keymap.run_action",
                    -- ["dd"] = { "keymap.run_action", opts = { action = "dispose" }, desc = "Dispose task" },
                    ["<c-e>"] = false,
                    ["e"] = { "keymap.run_action", opts = { action = "edit" }, desc = "Edit task" },
                    -- ["o"] = "keymap.open",
                    ["<c-v>"] = false,
                    ["v"] = { "keymap.open", opts = { dir = "vsplit" }, desc = "Open task output in vsplit" },
                    ["<c-s>"] = false,
                    ["V"] = { "keymap.open", opts = { dir = "split" }, desc = "Open task output in split" },
                    ["<c-t>"] = false,
                    ["t"] = { "keymap.open", opts = { dir = "tab" }, desc = "Open task output in tab" },
                    -- ["<C-f>"] = { "keymap.open", opts = { dir = "float" }, desc = "Open task output in float" },
                    ["f"] = { "keymap.open", opts = { dir = "float" }, desc = "Open task output in float" },
                    -- ["<C-q>"] = {
                    --     "keymap.run_action",
                    --     opts = { action = "open output in quickfix" },
                    --     desc = "Open task output in the quickfix",
                    -- },
                    -- ["p"] = "keymap.toggle_preview",
                    -- ["{"] = "keymap.prev_task",
                    -- ["}"] = "keymap.next_task",
                    ["<c-k>"] = false,
                    ["<c-f>"] = "keymap.scroll_output_up",
                    ["<c-j>"] = false,
                    ["<c-b>"] = "keymap.scroll_output_down",
                    -- ["g."] = "keymap.toggle_show_wrapped",
                    -- ["q"] = { "<CMD>close<CR>", desc = "Close task list" },
                },
            },
            -- Aliases for bundles of components. Redefine the builtins, or create your own.
            component_aliases = {
                -- Most tasks are initialized with the default components
                default = {
                    "on_exit_set_status",
                    "on_complete_notify",
                    { "on_complete_dispose",      require_view = { "SUCCESS", "FAILURE" } },
                    { "user.set_output_filetype", filetype = "OverseerOutput" },
                },
            },
        },
    },
}
