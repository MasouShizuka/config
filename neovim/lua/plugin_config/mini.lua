local variables = require("variables")

require("mini.ai").setup(
    {
        custom_textobjects = {
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
                    "%f[%w]()%w+()_",
                    "_()%w+()%f[%W]",
                    "%f[%w]()%w+()-",
                    "-()%w+()%f[%W]",
                    "[^_-]%f[%u]()()%u[%l%d]+()()%f[^%l%d][^_-]",
                    "[^_-%w]()()[%l%d]+()()%u",
                    "^()()[%l%d]+()()%u",
                },
            },
        },
    }
)

require("mini.align").setup(
    {
        mappings = {
            start = "ga",
            start_with_preview = "gA",
        },
    }
)

require("mini.splitjoin").setup(
    {
        mappings = {
            -- toggle = "gS",
            toggle = "gs",
        },
    }
)

require("mini.surround").setup(
    {
        custom_surroundings = {
            B = {
                input = { "%{().-()%}" },
                output = { left = "{", right = "}" },
            },
            L = {
                input = { "\\begin%{%w*%}\n().-()\n\\end%{%w*%}" },
                output = function()
                    local latex_name = require("mini.surround").user_input("Latex object name")
                    return { left = ("\\begin{%s}\n"):format(latex_name), right = ("\n\\end{%s}"):format(latex_name) }
                end,
            },
            l = {
                input = { "\\%w+%{().-()%}" },
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
    }
)

if not variables.is_vscode then
    require("mini.comment").setup(
        {
            mappings = {
                -- Toggle comment (like `gcip` - comment inner paragraph) for both
                -- Normal and Visual modes
                comment = "gc",
                -- Toggle comment on current line
                comment_line = "gcc",
                -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                textobject = "gc",
            },
        }
    )

    require("mini.indentscope").setup(
        {
            draw = {
                -- delay = 100,
                delay = 0,
                animation = require("mini.indentscope").gen_animation.none(),
            },
        }
    )

    require("mini.pairs").setup()

    require("mini.trailspace").setup()
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            require("mini.trailspace").trim()
        end,
        pattern = "*",
    })
end
