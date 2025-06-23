local environment = require("utils.environment")

return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerSaveBundle",
            "OverseerLoadBundle",
            "OverseerDeleteBundle",
            "OverseerRunCmd",
            "OverseerRun",
            "OverseerInfo",
            "OverseerBuild",
            "OverseerQuickAction",
            "OverseerTaskAction",
            "OverseerClearCache",
        },
        enabled = not environment.is_vscode,
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>o",  group = "overseer",        mode = "n" },
                            { "<leader>oB", group = "overseer bundle", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for overseer",
                    pattern = "IceLoad",
                })
            end
        end,
        keys = {
            { "<leader>oo",  function() vim.api.nvim_command("OverseerToggle") end,             desc = "Toggle the overseer window. With ! cursor stays in current window",    mode = "n" },
            { "<leader>oBs", function() vim.api.nvim_command("OverseerSaveBundle") end,         desc = "Serialize and save the current tasks to disk",                         mode = "n" },
            { "<leader>oBl", function() vim.api.nvim_command("OverseerLoadBundle") end,         desc = "Load tasks that were saved to disk. With ! tasks will not be started", mode = "n" },
            { "<leader>oBd", function() vim.api.nvim_command("OverseerDeleteBundle") end,       desc = "Delete a saved task bundle",                                           mode = "n" },
            { "<leader>oc",  function() vim.api.nvim_command("OverseerRunCmd") end,             desc = "Run a raw shell command",                                              mode = "n" },
            { "<leader>or",  function() vim.api.nvim_command("OverseerRun") end,                desc = "Run a task from a template",                                           mode = "n" },
            { "<leader>oi",  function() vim.api.nvim_command("OverseerInfo") end,               desc = "Display diagnostic information about overseer",                        mode = "n" },
            { "<leader>ob",  function() vim.api.nvim_command("OverseerBuild") end,              desc = "Open the task builder",                                                mode = "n" },
            { "<leader>oq",  function() vim.api.nvim_command("OverseerQuickAction") end,        desc = "Run an action on the most recent task, or the task under the cursor",  mode = "n" },
            { "<leader>ot",  function() vim.api.nvim_command("OverseerTaskAction") end,         desc = "Select a task to run an action on",                                    mode = "n" },
            { "<leader>oC",  function() vim.api.nvim_command("OverseerClearCache") end,         desc = "Clear the task cache",                                                 mode = "n" },
            { "<leader>r",   function() require("overseer").run_template({ name = "run" }) end, desc = "Run",                                                                  mode = "n" },
        },
        opts = {
            -- Template modules to load
            templates = {
                "shell",
                "vscode",
                "user.cargo",
                "user.latex",
                "user.run",
            },
            -- Configure the task list
            task_list = {
                -- Default direction. Can be "left", "right", or "bottom"
                direction = "right",
                -- Set keymap to false to remove default behavior
                -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
                bindings = {
                    -- ["?"] = "ShowHelp",
                    -- ["g?"] = "ShowHelp",
                    -- ["<CR>"] = "RunAction",
                    ["<c-e>"] = false,
                    ["e"] = "Edit",
                    -- ["o"] = "Open",
                    ["<c-v>"] = false,
                    ["v"] = "OpenVsplit",
                    ["<c-s>"] = false,
                    ["V"] = "OpenSplit",
                    -- ["<C-f>"] = "OpenFloat",
                    ["f"] = "OpenFloat",
                    -- ["<C-q>"] = "OpenQuickFix",
                    -- ["p"] = "TogglePreview",
                    ["<c-l>"] = false,
                    ["J"] = "IncreaseDetail",
                    ["<c-h>"] = false,
                    ["K"] = "DecreaseDetail",
                    -- ["L"] = "IncreaseAllDetail",
                    -- ["H"] = "DecreaseAllDetail",
                    -- ["["] = "DecreaseWidth",
                    -- ["]"] = "IncreaseWidth",
                    -- ["{"] = "PrevTask",
                    -- ["}"] = "NextTask",
                    ["<c-k>"] = false,
                    ["<c-f>"] = "ScrollOutputDown",
                    ["<c-j>"] = false,
                    ["<c-b>"] = "ScrollOutputUp",
                    -- ["q"] = "Close",
                },
            },
            task_launcher = {
                -- Set keymap to false to remove default behavior
                -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
                bindings = {
                    i = {
                        -- ["<C-s>"] = "Submit",
                        -- ["<C-c>"] = "Cancel",
                    },
                    n = {
                        -- ["<CR>"] = "Submit",
                        -- ["<C-s>"] = "Submit",
                        -- ["q"] = "Cancel",
                        -- ["?"] = "ShowHelp",
                    },
                },
            },
            task_editor = {
                -- Set keymap to false to remove default behavior
                -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
                bindings = {
                    i = {
                        -- ["<CR>"] = "NextOrSubmit",
                        -- ["<C-s>"] = "Submit",
                        -- ["<Tab>"] = "Next",
                        -- ["<S-Tab>"] = "Prev",
                        -- ["<C-c>"] = "Cancel",
                    },
                    n = {
                        -- ["<CR>"] = "NextOrSubmit",
                        ["<CR>"] = "Submit",
                        -- ["<C-s>"] = "Submit",
                        -- ["<Tab>"] = "Next",
                        -- ["<S-Tab>"] = "Prev",
                        -- ["q"] = "Cancel",
                        -- ["?"] = "ShowHelp",
                    },
                },
            },
            -- Aliases for bundles of components. Redefine the builtins, or create your own.
            component_aliases = {
                -- Most tasks are initialized with the default components
                default = {
                    { "display_duration",         detail_level = 2 },
                    "on_output_summarize",
                    "on_exit_set_status",
                    "on_complete_notify",
                    { "on_complete_dispose",      require_view = { "SUCCESS", "FAILURE" } },
                    { "user.set_output_filetype", filetype = "OverseerOutput" },
                },
            },
        },
    },
}
