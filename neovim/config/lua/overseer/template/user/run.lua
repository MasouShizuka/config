local environment = require("utils.environment")
local lsp = require("utils.lsp")
local utils = require("utils")

return {
    name = "run",
    builder = function()
        local curr_file = vim.fn.expand("%:~:.")
        local output = vim.fn.expand("%:.:r")
        if environment.is_windows then
            curr_file = curr_file:gsub("\\", "/")
            output = output:gsub("\\", "/") .. ".exe"
        end

        local cmd = curr_file
        local args
        local components = { "default" }

        local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        if ft == "cpp" then
            cmd = "rm"
            args = { "./" .. output }
            components = {
                {
                    "dependencies",
                    task_names = {
                        {
                            cmd = "g++",
                            args = {
                                "-static-libstdc++",
                                curr_file,
                                "-o",
                                output,
                            },
                            components = {
                                { "on_complete_notify", statuses = { "FAILURE" } },
                                "default",
                            },
                        },
                        {
                            cmd = "./" .. output,
                            components = {
                                { "on_complete_notify", statuses = { "FAILURE" } },
                                { "open_output",        on_start = "never",      on_complete = "always" },
                                "default",
                            },
                        },
                    },
                    sequential = true,
                },
                { "on_complete_notify", statuses = { "FAILURE" } },
                "default",
            }
        elseif ft == "lua" then
            cmd = "lua"
            args = { curr_file }
            components = {
                { "on_complete_notify", statuses = { "FAILURE" } },
                { "open_output",        on_start = "never",      on_complete = "always" },
                "default",
            }
        elseif ft == "markdown" then
            cmd = "echo"
            args = { "Toggling markdown-preview" }
            components = {
                { "on_complete_dispose", timeout = 1 },
                { "on_complete_notify",  statuses = { "FAILURE" } },
                "default",
            }
            if utils.is_available("markdown-preview.nvim") then
                vim.api.nvim_command("MarkdownPreviewToggle")
            end
        elseif ft == "python" then
            cmd = "python"
            args = { "-u", curr_file }
            components = {
                { "on_complete_notify", statuses = { "FAILURE" } },
                { "open_output",        on_start = "never",      on_complete = "always" },
                "default",
            }
        elseif ft == "rust" then
            cmd = "cargo run"
            components = {
                { "on_complete_notify", statuses = { "FAILURE" } },
                { "open_output",        on_start = "never",      on_complete = "always" },
                "default",
            }
        elseif ft == "sh" then
            cmd = "sh"
            args = { curr_file }
            components = {
                { "on_complete_notify", statuses = { "FAILURE" } },
                { "open_output",        on_start = "never",      on_complete = "always" },
                "default",
            }
        elseif ft == "tex" then
            cmd = "echo"
            args = { "Texlab building" }
            components = {
                { "on_complete_dispose", timeout = 1 },
                { "on_complete_notify",  statuses = { "FAILURE" } },
                "default",
            }
            if vim.tbl_contains(lsp.lsp_list, "texlab") then
                vim.api.nvim_command("TexlabBuild")
            end
        end

        return {
            cmd = cmd,
            args = args,
            components = components,
        }
    end,
    condition = {
        filetype = {
            "cpp",
            "lua",
            "markdown",
            "python",
            "rust",
            "sh",
            "tex",
        },
    },
}
