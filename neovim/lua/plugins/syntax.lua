local environment = require("utils.environment")
local treesitter = require("utils.treesitter")
local utils = require("utils")

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
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
                    mode = "n",
                    ["s"] = {
                        name = "+mini.surround",
                    },
                })
            end
        end,
        opts = {
            custom_surroundings = {
                [","] = {
                    input = { "%<().-()%>" },
                    output = { left = "<", right = ">" },
                },
                ["."] = {
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
                add = "sa",    -- Add surrounding in Normal and Visual modes
                delete = "sd", -- Delete surrounding
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
            n_lines = math.huge,
            respect_selection_type = true,
        },
        version = false,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = {
            ":TSUpdate",
        },
        cmd = {
            "TSBufDisable",
            "TSBufEnable",
            "TSBufToggle",
            "TSDisable",
            "TSEnable",
            "TSToggle",
            "TSInstall",
            "TSInstallInfo",
            "TSInstallSync",
            "TSModuleInfo",
            "TSUninstall",
            "TSUpdate",
            "TSUpdateSync",
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        event = {
            "User TreesitterFile",
        },
        init = function(plugin)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treeitter** module to be loaded in time.
            -- Luckily, the only thins that those plugins need are the custom queries, which we make available
            -- during startup.
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        opts = function()
            local opts = {
                ensure_installed = treesitter.treesitter,
                highlight = {
                    enable = not environment.is_vscode,
                    disable = function(lang, buf)
                        return not vim.tbl_contains(treesitter.treesitter_filetype_list, lang) and utils.is_bigfile(buf) or utils.is_longfile(buf)
                    end,
                },
                indent = {
                    enable = true,
                },
            }

            if utils.is_available("nvim-treesitter-textobjects") then
                local textobjects = {}

                textobjects["select"] = {
                    enable = true,
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["ak"] = { query = "@block.outer", desc = "Around block" },
                        ["ik"] = { query = "@block.inner", desc = "Inside block" },
                        ["ac"] = { query = "@class.outer", desc = "Around class" },
                        ["ic"] = { query = "@class.inner", desc = "Inside class" },
                        ["af"] = { query = "@function.outer", desc = "Around function " },
                        ["if"] = { query = "@function.inner", desc = "Inside function " },
                        ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
                        ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
                    },
                }

                textobjects["swap"] = {
                    enable = true,
                    swap_next = {
                        ["sXk"] = { query = "@block.outer", desc = "Swap next block" },
                        ["sXf"] = { query = "@function.outer", desc = "Swap next function" },
                        ["sXa"] = { query = "@parameter.inner", desc = "Swap next argument" },
                    },
                    swap_previous = {
                        ["sXK"] = { query = "@block.outer", desc = "Swap previous block" },
                        ["sXF"] = { query = "@function.outer", desc = "Swap previous function" },
                        ["sXA"] = { query = "@parameter.inner", desc = "Swap previous argument" },
                    },
                }

                textobjects["move"] = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]k"] = { query = "@block.outer", desc = "Next block start" },
                        ["]f"] = { query = "@function.outer", desc = "Next function start" },
                        ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
                    },
                    goto_next_end = {
                        ["]K"] = { query = "@block.outer", desc = "Next block end" },
                        ["]F"] = { query = "@function.outer", desc = "Next function end" },
                        ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
                    },
                    goto_previous_start = {
                        ["[k"] = { query = "@block.outer", desc = "Previous block start" },
                        ["[f"] = { query = "@function.outer", desc = "Previous function start" },
                        ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
                    },
                    goto_previous_end = {
                        ["[K"] = { query = "@block.outer", desc = "Previous block end" },
                        ["[F"] = { query = "@function.outer", desc = "Previous function end" },
                        ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
                    },
                }

                opts["textobjects"] = textobjects
            end

            return opts
        end,
        version = false,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        cmd = {
            "TSContextEnable",
            "TSContextDisable",
            "TSContextToggle",
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        enabled = not environment.is_vscode,
        event = {
            "User TreesitterFile",
        },
        opts = {
            enable = true,         -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 0,         -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            -- multiline_threshold = 20, -- Maximum number of lines to show for a single context
            multiline_threshold = 1, -- Maximum number of lines to show for a single context
            trim_scope = "outer",    -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = "cursor",         -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = nil,
            zindex = 20,     -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        },
    },
}
