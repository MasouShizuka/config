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

            -- lazyvim.plugins.treesitter
            -- When in diff mode, we want to use the default
            -- vim text objects c & C instead of the treesitter ones.
            local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
            local configs = require("nvim-treesitter.configs")
            for name, fn in pairs(move) do
                if name:find("goto") == 1 then
                    move[name] = function(q, ...)
                        if vim.wo.diff then
                            local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                            for key, query in pairs(config or {}) do
                                if q == query and key:find("[%]%[][cC]") then
                                    vim.cmd("normal! " .. key)
                                    return
                                end
                            end
                        end
                        return fn(q, ...)
                    end
                end
            end
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        enabled = environment.treesitter_enable,
        event = {
            "User TreesitterFile",
        },
        init = function(plugin)
            -- lazyvim.plugins.treesitter
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom queries, which we make available
            -- during startup.
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        opts = function()
            local utils = require("utils")

            local opts = {
                -- A list of parser names, or "all"
                ensure_installed = require("utils.treesitter").treesitter,

                -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
                highlight = {
                    enable = not environment.is_vscode,
                    disable = function(lang, buf)
                        return utils.is_bigfile(buf) or utils.is_longfile(buf)
                    end,
                },

                indent = {
                    enable = true,
                },
            }

            if utils.is_available("nvim-treesitter-textobjects") then
                local textobjects = {}

                if not utils.is_available("mini.ai") then
                    textobjects["select"] = {
                        enable = true,

                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["ao"] = { query = "@block.outer", desc = "Around block" },
                            ["io"] = { query = "@block.inner", desc = "Inside block" },
                            ["ac"] = { query = "@class.outer", desc = "Around class" },
                            ["ic"] = { query = "@class.inner", desc = "Inside class" },
                            ["af"] = { query = "@function.outer", desc = "Around function " },
                            ["if"] = { query = "@function.inner", desc = "Inside function " },
                            ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
                            ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
                        },
                    }
                end

                textobjects["swap"] = {
                    enable = true,
                    swap_next = {
                        ["sXa"] = { query = "@parameter.inner", desc = "Swap next argument" },
                    },
                    swap_previous = {
                        ["sXA"] = { query = "@parameter.inner", desc = "Swap previous argument" },
                    },
                }

                textobjects["move"] = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]o"] = { query = "@block.outer", desc = "Next block start" },
                        ["]c"] = { query = "@class.outer", desc = "Next class start" },
                        ["]f"] = { query = "@function.outer", desc = "Next function start" },
                        ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
                    },
                    goto_next_end = {
                        ["]O"] = { query = "@block.outer", desc = "Next block end" },
                        ["]C"] = { query = "@class.outer", desc = "Next class end" },
                        ["]F"] = { query = "@function.outer", desc = "Next function end" },
                        ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
                    },
                    goto_previous_start = {
                        ["[o"] = { query = "@block.outer", desc = "Previous block start" },
                        ["[c"] = { query = "@class.outer", desc = "Previous class start" },
                        ["[f"] = { query = "@function.outer", desc = "Previous function start" },
                        ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
                    },
                    goto_previous_end = {
                        ["[O"] = { query = "@block.outer", desc = "Previous block end" },
                        ["[C"] = { query = "@class.outer", desc = "Previous class end" },
                        ["[F"] = { query = "@function.outer", desc = "Previous function end" },
                        ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
                    },
                }

                opts["textobjects"] = textobjects
            end

            return opts
        end,
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
        enabled = not environment.is_vscode and environment.treesitter_enable,
        event = {
            "User TreesitterFile",
        },
        opts = {
            multiline_threshold = 1, -- Maximum number of lines to show for a single context
        },
    },
}
