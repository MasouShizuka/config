local environment = require("utils.environment")
local path = require("utils.path")

return {
    -- NOTE: leetcode.nvim 使用 curl 来 post 数据，需要安装 curl
    -- msys2 默认的 curl 对于 windows 存在一定的问题，比如在 powershell 中，-d 中的文件内容需要用单引号包裹
    -- 最好选择安装 mingw-w64-ucrt-x86_64-curl，并记得将环境变量中 msys64/ucrt64/bin 放在 msys64/usr/bin 之上
    {
        "kawre/leetcode.nvim",
        build = {
            ":TSUpdate html",
        },
        cmd = {
            "Leet",
        },
        config = function(_, opts)
            require("leetcode").setup(opts)

            if require("utils").is_available("which-key.nvim") then
                require("which-key").add({
                    {
                        mode = "n",
                        { "<leader>L",  group = "leet" },
                        { "<leader>Lp", group = "problem" },
                        { "<leader>LS", group = "session" },
                        { "<leader>Ld", group = "desc" },
                        { "<leader>LO", group = "cookie" },
                    },
                })
            end

            vim.keymap.set("n", "<leader>Lm", function() vim.api.nvim_command("Leet menu") end, { desc = "menu", silent = true })
            vim.keymap.set("n", "<leader>Lq", function() vim.api.nvim_command("Leet exit") end, { desc = "exit", silent = true })
            vim.keymap.set("n", "<leader>Lc", function() vim.api.nvim_command("Leet console") end, { desc = "console", silent = true })
            vim.keymap.set("n", "<leader>Li", function() vim.api.nvim_command("Leet info") end, { desc = "info", silent = true })
            vim.keymap.set("n", "<leader>Lt", function() vim.api.nvim_command("Leet tabs") end, { desc = "tabs", silent = true })
            vim.keymap.set("n", "<leader>Ly", function() vim.api.nvim_command("Leet yank") end, { desc = "yank", silent = true })
            vim.keymap.set("n", "<leader>Ll", function() vim.api.nvim_command("Leet lang") end, { desc = "lang", silent = true })
            vim.keymap.set("n", "<leader>Lr", function() vim.api.nvim_command("Leet run") end, { desc = "run", silent = true })
            vim.keymap.set("n", "<leader>Ls", function() vim.api.nvim_command("Leet submit") end, { desc = "submit", silent = true })
            vim.keymap.set("n", "<leader>Lpr", function() vim.api.nvim_command("Leet random") end, { desc = "random", silent = true })
            vim.keymap.set("n", "<leader>Lpd", function() vim.api.nvim_command("Leet daily") end, { desc = "daily", silent = true })
            vim.keymap.set("n", "<leader>Lpl", function() vim.api.nvim_command("Leet list") end, { desc = "list", silent = true })
            vim.keymap.set("n", "<leader>Lo", function() vim.api.nvim_command("Leet open") end, { desc = "open", silent = true })
            vim.keymap.set("n", "<leader>LU", function() vim.api.nvim_command("Leet reset") end, { desc = "reset", silent = true })
            vim.keymap.set("n", "<leader>Lu", function() vim.api.nvim_command("Leet last_submit") end, { desc = "last_submit", silent = true })
            vim.keymap.set("n", "<leader>LR", function() vim.api.nvim_command("Leet restore") end, { desc = "restore", silent = true })
            vim.keymap.set("n", "<leader>LI", function() vim.api.nvim_command("Leet inject") end, { desc = "inject", silent = true })
            vim.keymap.set("n", "<leader>LSc", function() vim.api.nvim_command("Leet session create") end, { desc = "create", silent = true })
            vim.keymap.set("n", "<leader>LSc", function() vim.api.nvim_command("Leet session change") end, { desc = "change", silent = true })
            vim.keymap.set("n", "<leader>LSc", function() vim.api.nvim_command("Leet session update") end, { desc = "update", silent = true })
            vim.keymap.set("n", "<leader>Ldt", function() vim.api.nvim_command("Leet desc toggle") end, { desc = "toggle", silent = true })
            vim.keymap.set("n", "<leader>Lds", function() vim.api.nvim_command("Leet desc stats") end, { desc = "stats", silent = true })
            vim.keymap.set("n", "<leader>LOu", function() vim.api.nvim_command("Leet cookie update") end, { desc = "update", silent = true })
            vim.keymap.set("n", "<leader>LOd", function() vim.api.nvim_command("Leet cookie delete") end, { desc = "delete", silent = true })
            vim.keymap.set("n", "<leader>La", function() vim.api.nvim_command("Leet cache update") end, { desc = "cache update", silent = true })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        lazy = "leetcode" ~= vim.fn.argv()[1],
        opts = function()
            local directory = path.data_path .. "/leetcode"
            if vim.fn.isdirectory(directory) == 0 then
                vim.fn.mkdir(directory)
            end
            -- plenary 在 windows 下必须传入 \ 作为路径分隔符，否则路径不正确
            if environment.is_windows then
                directory = directory:gsub("/", "\\")
            end

            return {
                ---@type string
                arg = "leetcode",

                cn = { -- leetcode.cn
                    enabled = true, ---@type boolean
                },

                ---@type lc.storage
                storage = {
                    home = directory,
                    cache = directory,
                },

                ---@type table<lc.lang, lc.inject>
                injector = {
                    ["cpp"] = {
                        before = {
                            "#include <algorithm>",
                            "#include <cmath>",
                            "#include <deque>",
                            "#include <iostream>",
                            "#include <map>",
                            "#include <queue>",
                            "#include <set>",
                            "#include <stack>",
                            "#include <unordered_map>",
                            "#include <unordered_set>",
                            "#include <vector>",
                            "",
                            "using namespace std;",
                        },
                    },
                },

                keys = {
                    toggle = { "q", "<esc>" }, ---@type string|string[]
                    -- confirm = { "<cr>" }, ---@type string|string[]

                    -- reset_testcases = "r", ---@type string
                    -- use_testcase = "U", ---@type string
                    focus_testcases = "<c-k>", ---@type string
                    focus_result = "<c-j>", ---@type string
                },
            }
        end,
    },
}
