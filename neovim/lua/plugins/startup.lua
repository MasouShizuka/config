local variables = require("config.variables")

return {
    -- {
    --     "goolord/alpha-nvim",
    --     cmd = {
    --         "Alpha",
    --     },
    --     config = function(_, opts)
    --         require("alpha").setup(opts.config)

    --         -- 显示 plugins 加载时间
    --         vim.api.nvim_create_autocmd("User", {
    --             callback = function()
    --                 local stats = require("lazy").stats()
    --                 local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
    --                 opts.section.footer.val = { ("󱐋 Neovim loaded %s plugins   in %s ms 󱐋"):format(stats.count, ms) }
    --                 opts.section.footer.opts.hl = "DashboardFooter"
    --                 pcall(vim.cmd.AlphaRedraw)
    --             end,
    --             desc = "Add Alpha dashboard footer",
    --             group = vim.api.nvim_create_augroup("AlphaFooter", { clear = true }),
    --             once = true,
    --             pattern = "LazyVimStarted",
    --         })
    --     end,
    --     dependencies = {
    --         "nvim-tree/nvim-web-devicons",
    --     },
    --     enabled = not variables.is_vscode,
    --     init = function()
    --         -- 判断是否启动 alpha
    --         vim.api.nvim_create_autocmd("VimEnter", {
    --             callback = function()
    --                 local should_skip = false
    --                 local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
    --                 if
    --                     vim.fn.argc() > 0                                                                                    -- don't start when opening a file
    --                     or #lines > 1                                                                                        -- don't open if current buffer has more than 1 line
    --                     or (#lines == 1 and lines[1]:len() > 0)                                                              -- don't open the current buffer if it has anything on the first line
    --                     or #vim.tbl_filter(function(bufnr) return vim.bo[bufnr].buflisted end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
    --                     or not vim.o.modifiable                                                                              -- don't open if not modifiable
    --                 then
    --                     should_skip = true
    --                 else
    --                     for _, arg in pairs(vim.v.argv) do
    --                         if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
    --                             should_skip = true
    --                             break
    --                         end
    --                     end
    --                 end
    --                 if not should_skip then
    --                     require("alpha").start(true)
    --                 end
    --             end,
    --             desc = "Start alpha when vim is opened with no arguments",
    --             group = vim.api.nvim_create_augroup("AlphaStart", { clear = true }),
    --         })
    --     end,
    --     opts = function()
    --         local dashboard = require("alpha.themes.dashboard")

    --         dashboard.section.header.val = {
    --             " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗ ",
    --             " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║ ",
    --             " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║ ",
    --             " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ",
    --             " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ",
    --             " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ",
    --         }

    --         -- local config_session = variables.config_path:gsub("/", vim.g.path_replacer):gsub(":", vim.g.colon_replacer)
    --         dashboard.section.buttons.val = {
    --             dashboard.button("n", "  New File", ":ene <bar> startinsert<cr>"),
    --             dashboard.button("f", "  Find File", ":Telescope find_files<cr>"),
    --             dashboard.button("c", "  Config", [[:execute "cd " . fnamemodify($MYVIMRC, ":p:h")<cr>:SessionManager load_current_dir_session<cr>]]),
    --             dashboard.button("s", "  Load Session", ":SessionManager load_session<cr>"),
    --             dashboard.button("S", "  Load Last Session", ":SessionManager load_last_session<cr>"),
    --             -- 启用 resession 时取消注释
    --             -- dashboard.button("c", "  Config", [[:execute "cd " . fnamemodify($MYVIMRC, ":p:h")<cr>:lua require("resession").load("]] .. config_session .. [[")<cr>]]),
    --             -- dashboard.button("s", "  Load Session", [[:lua require("resession").load()<cr>]]),
    --             -- dashboard.button("S", "  Load Last Session", [[:lua require("resession").load("last")<cr>]]),
    --             dashboard.button("l", "  Lazy", ":Lazy<cr>"),
    --             dashboard.button("q", "  Quit", ":qa<cr>"),
    --         }

    --         return dashboard
    --     end,
    -- },

    {
        "nvimdev/dashboard-nvim",
        cmd = {
            "Dashboard",
            "DbProjectDelete",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        init = function()
            -- 判断是否启动 dashboard
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    local should_skip = false
                    local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
                    if
                        vim.fn.argc() > 0                                                                                    -- don't start when opening a file
                        or #lines > 1                                                                                        -- don't open if current buffer has more than 1 line
                        or (#lines == 1 and lines[1]:len() > 0)                                                              -- don't open the current buffer if it has anything on the first line
                        or #vim.tbl_filter(function(bufnr) return vim.bo[bufnr].buflisted end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
                        or not vim.o.modifiable                                                                              -- don't open if not modifiable
                    then
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
                        require("dashboard")
                    end
                end,
                desc = "Start dashboard when vim is opened with no arguments",
                group = vim.api.nvim_create_augroup("DashboardStart", { clear = true }),
            })
        end,
        opts = function()
            local logo = {
                "                                                      ",
                "                                                      ",
                "███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
                "████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
                "██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
                "██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
                "██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
                "                                                      ",
                "                                                      ",
            }

            local opts = {
                theme = "doom",
                config = {
                    header = logo,
                    center = {
                        {
                            icon = "  ",
                            desc = "New File",
                            key = "n",
                            action = function()
                                vim.cmd.enew()
                                vim.cmd.startinsert()
                            end,
                        },
                        { icon = "  ", desc = "Find File", key = "f", action = function() vim.api.nvim_command("Telescope find_files") end },
                        { icon = "  ", desc = "Find Text", key = "/", action = function() vim.api.nvim_command("Telescope live_grep") end },
                        {
                            icon = "  ",
                            desc = "Config",
                            key = "c",
                            action = function()
                                vim.api.nvim_set_current_dir(vim.fn.fnamemodify(vim.env.MYVIMRC, ":p:h"))
                                vim.api.nvim_command("SessionManager load_current_dir_session")
                            end,
                        },
                        { icon = "  ", desc = "Load Session", key = "s", action = function() vim.api.nvim_command("SessionManager load_session") end },
                        { icon = "  ", desc = "Load Last Session", key = "S", action = function() vim.api.nvim_command("SessionManager load_last_session") end },
                        { icon = "  ", desc = "Lazy", key = "l", action = function() require("lazy").home() end },
                        { icon = "  ", desc = "Quit", key = "q", action = function() vim.cmd.quitall() end },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        return { string.format("󱐋 Neovim loaded %s plugins   in %s ms 󱐋", stats.count, ms) }
                    end,
                },
                hide = {
                    statusline = false,
                    tabline = false,
                    winbar = true,
                },
            }

            vim.api.nvim_set_hl(0, "DashboardHeader", { link = "yellow" })
            for _, button in ipairs(opts.config.center) do
                button.desc = button.desc .. string.rep(" ", 48 - #button.desc)
                button.icon_hl = "purple"
                button.key_hl = "red"
                button.key_format = " %s"
            end
            vim.api.nvim_set_hl(0, "DashboardFooter", { link = "blue" })

            return opts
        end,
    },
}
