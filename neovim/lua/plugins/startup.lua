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
                group = vim.api.nvim_create_augroup("alpha", { clear = true }),
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

            dashboard.section.buttons.val = {
                dashboard.button("n", " " .. " New File", ":ene <bar> startinsert<cr>"),
                dashboard.button("f", " " .. " Find File", ":Telescope find_files<cr>"),
                dashboard.button("o", " " .. " Recent Files", ":Telescope oldfiles<cr>"),
                dashboard.button("c", " " .. " Config", ":e $MYVIMRC<cr>:cd %:h<cr>"),
                dashboard.button("s", " " .. " Restore Session", ":SessionManager load_session<cr>"),
                dashboard.button("S", " " .. " Restore Last Session", ":SessionManager load_last_session<cr>"),
                dashboard.button("l", " " .. " Lazy", ":Lazy<cr>"),
                dashboard.button("q", " " .. " Quit", ":qa<cr>"),
            }

            return dashboard
        end,
    },
}
