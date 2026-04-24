local environment = require("utils.environment")

return {
    {
        "echasnovski/mini.surround",
        keys = {
            { "sa", desc = "Add surrounding in Normal and Visual modes", mode = { "n", "x" } },
            { "sd", desc = "Delete surrounding",                         mode = { "n", "x" } },
            { "sf", desc = "Find surrounding (to the left)",             mode = { "n", "x" } },
            { "sF", desc = "Find surrounding (to the right)",            mode = { "n", "x" } },
            { "sh", desc = "Highlight surrounding",                      mode = { "n", "x" } },
            { "sr", desc = "Replace surrounding",                        mode = { "n", "x" } },
            { "sn", desc = "Update n_lines",                             mode = { "n", "x" } },
        },
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "s", group = "mini.surround", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for mini.surround",
                    pattern = "IceLoad",
                })
            end
        end,
        opts = {
            -- Add custom surroundings to be used on top of builtin ones. For more
            -- information with examples, see `:h MiniSurround.config`.
            custom_surroundings = {
                [","] = {
                    input = { "%b<>", "^.%s*().-()%s*.$" },
                    output = { left = "< ", right = " >" },
                },
                ["."] = {
                    input = { "%b<>", "^.().*().$" },
                    output = { left = "<", right = ">" },
                },
                B = {
                    input = { "%b{}", "^.().*().$" },
                    output = { left = "{", right = "}" },
                },
                L = {
                    input = { [[\begin%{.-%}().-()\end%{.-%}]] },
                    output = function()
                        local latex_name = require("mini.surround").user_input("Latex object name")
                        return { left = ([[\begin{%s}]]):format(latex_name), right = ([[\end{%s}]]):format(latex_name) }
                    end,
                },
                l = {
                    input = { [[\.*%{().-()%}]] },
                    output = function()
                        local cmd_name = require("mini.surround").user_input("Latex command name")
                        if cmd_name == nil then
                            return nil
                        end
                        return { left = ([[\%s{]]):format(cmd_name), right = "}" }
                    end,
                },
                r = {
                    input = { "%b[]", "^.().*().$" },
                    output = { left = "[", right = "]" },
                },
            },

            -- Module mappings. Use `''` (empty string) to disable one.
            mappings = {
                -- add = "sa",            -- Add surrounding in Normal and Visual modes
                -- delete = "sd",         -- Delete surrounding
                -- find = "sf",           -- Find surrounding (to the right)
                -- find_left = "sF",      -- Find surrounding (to the left)
                find = "sF",      -- Find surrounding (to the right)
                find_left = "sf", -- Find surrounding (to the left)
                -- highlight = "sh",      -- Highlight surrounding
                -- replace = "sr",        -- Replace surrounding
                -- update_n_lines = "sn", -- Update `n_lines`

                -- suffix_last = "p",     -- Suffix to search with "prev" method
                -- suffix_next = "n",     -- Suffix to search with "next" method
            },

            -- Number of lines within which surrounding is searched
            n_lines = math.huge,

            -- Whether to respect selection type:
            -- - Place surroundings on separate lines in linewise mode.
            -- - Place surroundings on each line in blockwise mode.
            respect_selection_type = true,
        },
    },

    -- NOTE: 需要安装 C 编译器，例如 msys2 中的 mingw-w64-ucrt-x86_64-gcc 或 mingw-w64-ucrt-x86_64-clang
    -- msys2 中自带的 gcc 编译的 parser 会使得 neovim 闪退
    -- 需要安装 tree-sitter，例如 msys2 中的 mingw-w64-ucrt-x86_64-tree-sitter
    {
        "romus204/tree-sitter-manager.nvim",
        cmd = {
            "TSManager",
        },
        cond = environment.treesitter_enable,
        event = {
            "User TreesitterFile",
        },
        opts = function()
            return {
                -- Default Options
                ensure_installed = require("utils.treesitter").treesitter, -- list of parsers to install at the start of a neovim session
                border = "rounded", -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
            }
        end,
    },
}
