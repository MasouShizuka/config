local variables = require("variables")

return {
    "goolord/alpha-nvim",
    cond = not variables.is_vscode,
    config = function(_, opts)
        require("alpha").setup(opts.config)

        -- 显示 plugins 加载时间
        vim.api.nvim_create_autocmd("UIEnter", {
            callback = function()
                local stats = require("lazy").stats()
                local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
                opts.section.footer.val =
                { "󱐋 Neovim loaded " .. stats.count .. " plugins   in " .. ms .. " ms 󱐋" }
                opts.section.footer.opts.hl = "DashboardFooter"
            end,
        })
    end,
    cmd = { "Alpha" },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    init = function()
        -- 判断是否启动 alpha
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("alpha", { clear = true }),
            callback = function()
                local should_skip = false
                if vim.fn.argc() > 0 or vim.fn.line2byte "$" ~= -1 or not vim.o.modifiable then
                    should_skip = true
                else
                    for _, arg in pairs(vim.v.argv) do
                        if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
                            should_skip = true
                            break
                        end
                    end
                end
                if not should_skip then require("alpha").start() end
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
            dashboard.button("n", " " .. " New File", ":ene <BAR> startinsert<CR>"),
            dashboard.button("f", " " .. " Find File", ":Telescope find_files<CR>"),
            dashboard.button("o", " " .. " Recent Files", ":Telescope oldfiles<CR>"),
            dashboard.button("c", " " .. " Config", ":e $MYVIMRC<CR>:cd %:h<CR>"),
            dashboard.button("s", " " .. " Restore Session", ":SessionManager load_session<CR>"),
            dashboard.button("S", " " .. " Restore Last Session", ":SessionManager load_last_session<CR>"),
            dashboard.button("l", " " .. " Lazy", ":Lazy<CR>"),
            dashboard.button("q", " " .. " Quit", ":qa<CR>"),
        }

        return dashboard
    end,
}
