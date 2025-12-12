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
        cond = not environment.is_vscode,
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

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, function()
                    vim.api.nvim_command(rhs)
                end, { desc = desc, silent = true })
            end

            map("n", "<leader>Lm", "Leet menu", "menu")
            map("n", "<leader>Lq", "Leet exit", "exit")
            map("n", "<leader>Lc", "Leet console", "console")
            map("n", "<leader>Li", "Leet info", "info")
            map("n", "<leader>Lt", "Leet tabs", "tabs")
            map("n", "<leader>Ly", "Leet yank", "yank")
            map("n", "<leader>Ll", "Leet lang", "lang")
            map("n", "<leader>Lr", "Leet run", "run")
            map("n", "<leader>Ls", "Leet submit", "submit")
            map("n", "<leader>Lpr","Leet random", "random")
            map("n", "<leader>Lpd","Leet daily", "daily")
            map("n", "<leader>Lpl","Leet list", "list")
            map("n", "<leader>Lo", "Leet open", "open")
            map("n", "<leader>LU", "Leet reset", "reset")
            map("n", "<leader>Lu", "Leet last_submit", "last_submit")
            map("n", "<leader>LR", "Leet restore", "restore")
            map("n", "<leader>LI", "Leet inject", "inject")
            map("n", "<leader>LSc","Leet session create", "create")
            map("n", "<leader>LSc","Leet session change", "change")
            map("n", "<leader>LSc","Leet session update", "update")
            map("n", "<leader>Ldt","Leet desc toggle", "toggle")
            map("n", "<leader>Lds","Leet desc stats", "stats")
            map("n", "<leader>LOu","Leet cookie update", "update")
            map("n", "<leader>LOd","Leet cookie delete", "delete")
            map("n", "<leader>La", "Leet cache update", "cache update")
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
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
