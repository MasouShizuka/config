local variables = require("config.variables")

return {
    {
        "goolord/alpha-nvim",
        cmd = {
            "Alpha",
        },
        config = function(_, opts)
            require("alpha").setup(opts.config)

            -- 显示 plugins 加载时间
            vim.api.nvim_create_autocmd("User", {
                callback = function()
                    local stats = require("lazy").stats()
                    local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
                    opts.section.footer.val = { "󱐋 Neovim loaded " .. stats.count .. " plugins   in " .. ms .. " ms 󱐋" }
                    opts.section.footer.opts.hl = "DashboardFooter"
                    pcall(vim.cmd.AlphaRedraw)
                end,
                desc = "Add Alpha dashboard footer",
                group = vim.api.nvim_create_augroup("alpha_add_footer", { clear = true }),
                once = true,
                pattern = "LazyVimStarted",
            })
        end,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        init = function()
            -- 判断是否启动 alpha
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    local should_skip = false
                    if vim.fn.argc() > 0 or vim.fn.line2byte("$") ~= -1 or not vim.o.modifiable then
                        should_skip = true
                    else
                        for _, arg in pairs(vim.v.argv) do
                            if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
                                should_skip = true
                                break
                            end
                        end
                    end
                    if not should_skip then
                        require("alpha").start()
                    end
                end,
                desc = "Start Alpha when vim is opened with no arguments",
                group = vim.api.nvim_create_augroup("alpha_start", { clear = true }),
            })
        end,
        opts = function()
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                        ",
                " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗ ",
                " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║ ",
                " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║ ",
                " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ",
                " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ",
                " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ",
                "                                                        ",
            }

            -- local config_session = variables.config_path:gsub("/", vim.g.path_replacer):gsub(":", vim.g.colon_replacer)
            dashboard.section.buttons.val = {
                dashboard.button("n", "  New File", ":ene <bar> startinsert<cr>"),
                dashboard.button("f", "  Find File", ":Telescope find_files<cr>"),
                dashboard.button("o", "  Recent Files", ":Telescope oldfiles<cr>"),
                dashboard.button("c", "  Config", [[:execute "cd " . fnamemodify($MYVIMRC, ":p:h")<cr>:SessionManager load_current_dir_session<cr>]]),
                dashboard.button("s", "  Load Session", ":SessionManager load_session<cr>"),
                dashboard.button("S", "  Load Last Session", ":SessionManager load_last_session<cr>"),
                -- 启用 resession 时取消注释
                -- dashboard.button("c", "  Config", [[:execute "cd " . fnamemodify($MYVIMRC, ":p:h")<cr>:lua require("resession").load("]] .. config_session .. [[")<cr>]]),
                -- dashboard.button("s", "  Load Session", [[:lua require("resession").load()<cr>]]),
                -- dashboard.button("S", "  Load Last Session", [[:lua require("resession").load("last")<cr>]]),
                dashboard.button("l", "  Lazy", ":Lazy<cr>"),
                dashboard.button("q", "  Quit", ":qa<cr>"),
            }

            return dashboard
        end,
    },
}
