local variables = require("config.variables")

return {
    {
        "echasnovski/mini.surround",
        config = function(_, opts)
            require("mini.surround").setup(opts)
        end,
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
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.register({
                    mode = "n",
                    ["s"] = {
                        name = "+mini.surround",
                    },
                })
            end
        end,
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
                    input = { "%[().-()%]" },
                    output = { left = "[", right = "]" },
                },
            },
            mappings = {
                add = "sa",            -- Add surrounding in Normal and Visual modes
                delete = "sd",         -- Delete surrounding
                -- find = "sf",           -- Find surrounding (to the right)
                -- find_left = "sF",      -- Find surrounding (to the left)
                find = "sF",
                find_left = "sf",
                highlight = "sh",      -- Highlight surrounding
                replace = "sr",        -- Replace surrounding
                update_n_lines = "sn", -- Update `n_lines`
                -- suffix_last = "l",     -- Suffix to search with "prev" method
                suffix_last = "p",     -- Suffix to search with "prev" method
                suffix_next = "n",     -- Suffix to search with "next" method
            },
            n_lines = 500,
            respect_selection_type = true,
        },
        version = false,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        keys = {
            { "<cr>", desc = "Treesitter incremental", mode = "n" },
            { "<bs>", desc = "Treesitter decremental", mode = "x" },
        },
        opts = {
            ensure_installed = {
                "bash",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "rust",
            },
            highlight = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<cr>",
                    node_decremental = "<bs>",
                    node_incremental = "<cr>",
                    scope_incremental = "<nop>",
                },
            },
            indent = { enable = true },
        },
        version = false,
    },
}
