local path = require("utils.path")

return {
    name = "latex build",
    builder = function()
        local magic_comment = {}
        for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
            local k, v = string.match(line, "%s*%%%s*!%s*TEX%s+(%w+)%s*=%s*(.*)")
            if not k then
                break
            end

            magic_comment[k:lower()] = v
        end

        local tex_program = "xelatex"
        local program = magic_comment["program"]
        if program then
            tex_program = program
        end

        local curr_file = vim.fn.expand("%:p:.")
        local tex_file = curr_file
        local root = magic_comment["root"]
        if root then
            tex_file = vim.fn.fnamemodify(curr_file, ":h") .. "/" .. root
        end

        local tex_file_no_ext = vim.fn.fnamemodify(tex_file, ":r")
        local pdf_file = tex_file_no_ext .. ".pdf"

        local cmd = path.sioyek_path
        local args = {
            "--nofocus",
            "--reuse-window",
            "--forward-search-file",
            curr_file,
            "--forward-search-line",
            tostring(vim.api.nvim_win_get_cursor(0)[1]),
            pdf_file,
        }
        local components = {
            {
                "dependencies",
                task_names = {
                    {
                        cmd = tex_program,
                        args = {
                            "-interaction=nonstopmode",
                            "-synctex=1",
                            tex_file,
                        },
                        components = {
                            { "on_complete_notify", statuses = { "FAILURE" } },
                            { "open_output",        on_start = "never",      on_complete = "failure" },
                            "default",
                        },
                    },
                    {
                        cmd = "bibtex",
                        args = {
                            tex_file_no_ext,
                        },
                        components = {
                            { "on_complete_notify", statuses = { "FAILURE" } },
                            { "open_output",        on_start = "never",      on_complete = "failure" },
                            "default",
                        },
                    },
                    {
                        cmd = tex_program,
                        args = {
                            "-interaction=nonstopmode",
                            "-synctex=1",
                            tex_file,
                        },
                        components = {
                            { "on_complete_notify", statuses = { "FAILURE" } },
                            { "open_output",        on_start = "never",      on_complete = "failure" },
                            "default",
                        },
                    },
                    {
                        cmd = tex_program,
                        args = {
                            "-interaction=nonstopmode",
                            "-synctex=1",
                            tex_file,
                        },
                        components = {
                            { "on_complete_notify", statuses = { "FAILURE" } },
                            { "open_output",        on_start = "never",      on_complete = "failure" },
                            "default",
                        },
                    },
                },
                sequential = true,
            },
            { "on_complete_notify", statuses = { "FAILURE" } },
            "default",
        }

        return {
            cmd = cmd,
            args = args,
            components = components,
        }
    end,
    condition = {
        filetype = { "tex" },
    },
}
