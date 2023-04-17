local variables = require("variables")

return {
    {
        "echasnovski/mini.ai",
        config = function(_, opts)
            require("mini.ai").setup(opts)
        end,
        event = "VeryLazy",
        opts = {
            custom_textobjects = {
                a = { "<().-()>" },
                e = function(ai_type)
                    local n_lines = vim.fn.line("$")
                    local start_line, end_line = 1, n_lines
                    if ai_type == "i" then
                        -- Skip first and last blank lines for `i` textobject
                        local first_nonblank, last_nonblank = vim.fn.nextnonblank(1), vim.fn.prevnonblank(n_lines)
                        start_line = first_nonblank == 0 and 1 or first_nonblank
                        end_line = last_nonblank == 0 and n_lines or last_nonblank
                    end

                    local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                    return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
                end,
                r = { { "%b[]" }, "^.().*().$" },
                v = {
                    {
                        "%f[%w]()%w+()[-_]",
                        "[-_]()%w+()%f[%W]",
                        "%f[-_%u]()%u[%d%l]+()%f[^-_%d%l]",
                        "%f[-_%w]()[%d%l]+()%f[^-_%d%l]",
                    },
                },
            },
            n_lines = 500,
        },
        version = false,
    },

    {
        "echasnovski/mini.align",
        config = function(_, opts)
            require("mini.align").setup(opts)
        end,
        keys = {
            { "ga", mode = { "n", "x" } },
            { "gA", mode = { "n", "x" } },
        },
        opts = {
            mappings = {
                start = "ga",
                start_with_preview = "gA",
            },
        },
        version = false,
    },

    {
        "echasnovski/mini.splitjoin",
        config = function(_, opts)
            require("mini.splitjoin").setup(opts)
        end,
        keys = {
            { "gs", mode = "n" },
        },
        opts = {
            mappings = {
                -- toggle = "gS",
                toggle = "gs",
            },
        },
        version = false,
    },

    {
        "echasnovski/mini.surround",
        config = function(_, opts)
            require("mini.surround").setup(opts)
        end,
        keys = {
            { "sa", mode = { "n", "x" } },
            { "sd", mode = { "n", "x" } },
            { "sf", mode = { "n", "x" } },
            { "sF", mode = { "n", "x" } },
            { "sh", mode = { "n", "x" } },
            { "sr", mode = { "n", "x" } },
            { "sn", mode = { "n", "x" } },
        },
        opts = {
            custom_surroundings = {
                a = {
                    input = { "%<().-()%>" },
                    output = { left = "<", right = ">" },
                },
                B = {
                    input = { "%{().-()%}" },
                    output = { left = "{", right = "}" },
                },
                L = {
                    input = { "\\begin%{.-%}().-()\\end%{.-%}" },
                    output = function()
                        local latex_name = require("mini.surround").user_input("Latex object name")
                        return { left = ("\\begin{%s}"):format(latex_name), right = ("\\end{%s}"):format(latex_name) }
                    end,
                },
                l = {
                    input = { "\\.*%{().-()%}" },
                    output = function()
                        local cmd_name = require("mini.surround").user_input("Latex command name")
                        if cmd_name == nil then return nil end
                        return { left = ("\\%s{"):format(cmd_name), right = "}" }
                    end,
                },
                r = {
                    input = { "%[().-()%]" },
                    output = { left = "[", right = "]" },
                },
            },
            mappings = {
                add = "sa",            -- Add surrounding in Normal and Visual modes
                delete = "sd",         -- Delete surrounding
                find = "sf",           -- Find surrounding (to the right)
                find_left = "sF",      -- Find surrounding (to the left)
                highlight = "sh",      -- Highlight surrounding
                replace = "sr",        -- Replace surrounding
                update_n_lines = "sn", -- Update `n_lines`
                -- suffix_last = "l",     -- Suffix to search with "prev" method
                suffix_last = "p",     -- Suffix to search with "prev" method
                suffix_next = "n",     -- Suffix to search with "next" method
            },
            respect_selection_type = true,
        },
        version = false,
    },



    {
        "echasnovski/mini.pairs",
        cond = not variables.is_vscode,
        config = function(_, opts)
            require("mini.pairs").setup(opts)
        end,
        event = "InsertEnter",
        version = false,
    },

    {
        "echasnovski/mini.trailspace",
        cond = not variables.is_vscode,
        config = function(_, opts)
            require("mini.trailspace").setup(opts)

            vim.api.nvim_create_autocmd("InsertLeave", {
                callback = function()
                    require("mini.trailspace").trim()
                end,
                pattern = "*",
            })
        end,
        event = "InsertLeave",
        version = false,
    },
}
