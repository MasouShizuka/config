local environment = require("utils.environment")

return {
    name = "run",
    builder = function()
        local curr_file = vim.fn.expand("%:p:.")
        local curr_file_no_ext = vim.fn.fnamemodify(curr_file, ":r")
        local output = curr_file_no_ext
        if environment.is_windows then
            curr_file = curr_file:gsub("\\", "/")
            output = output:gsub("\\", "/") .. ".exe"
        end

        local cmd = curr_file
        local args
        local components = { "default" }

        local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        if ft == "cpp" then
            cmd = "./" .. output
            components = {
                {
                    "dependencies",
                    task_names = {
                        {
                            cmd = "clang++",
                            args = {
                                "-static-libstdc++",
                                curr_file,
                                "-o",
                                output,
                                "-g",
                            },
                            components = {
                                { "on_complete_notify", statuses = { "FAILURE" } },
                                "default",
                            },
                        },
                    },
                    sequential = true,
                },
                { "on_complete_notify", statuses = { "FAILURE" } },
                { "open_output",        on_start = "never",      on_complete = "always" },
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
            if require("utils").is_available("markdown-preview.nvim") then
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
            if vim.tbl_contains(require("utils.lsp").lsp_list, "texlab") then
                vim.api.nvim_command("LspTexlabBuild")
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
