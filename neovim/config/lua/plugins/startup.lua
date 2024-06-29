local colors = require("utils.colors")
local environment = require("utils.environment")
local icons = require("utils.icons")

return {
    {
        "nvimdev/dashboard-nvim",
        cmd = {
            "Dashboard",
            "DbProjectDelete",
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        init = function()
            -- 判断是否启动 dashboard
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    local should_skip = false
                    local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
                    if
                        vim.fn.argc() > 0                                                                                                                        -- don't start when opening a file
                        or #lines > 1                                                                                                                            -- don't open if current buffer has more than 1 line
                        or (#lines == 1 and lines[1]:len() > 0)                                                                                                  -- don't open the current buffer if it has anything on the first line
                        or #vim.tbl_filter(function(bufnr) return vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
                        or not vim.o.modifiable                                                                                                                  -- don't open if not modifiable
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
                            icon = icons.misc.new_file .. " ",
                            desc = "New File",
                            key = "n",
                            action = function()
                                vim.cmd.enew()
                                vim.cmd.startinsert()
                            end,
                        },
                        { icon = icons.misc.search .. " ", desc = "Find File", key = "f", action = function() vim.api.nvim_command("Telescope find_files") end },
                        { icon = icons.misc.search .. " ", desc = "Find Text", key = "/", action = function() vim.api.nvim_command("Telescope live_grep") end },
                        {
                            icon = icons.misc.gear .. " ",
                            desc = "Config",
                            key = "c",
                            action = function()
                                vim.api.nvim_set_current_dir(vim.fn.fnamemodify(vim.env.MYVIMRC, ":p:h"))
                                vim.api.nvim_command("SessionManager load_current_dir_session")
                            end,
                        },
                        { icon = icons.misc.list_unordered .. " ", desc = "Load Session",      key = "s", action = function() vim.api.nvim_command("SessionManager load_session") end },
                        { icon = icons.misc.refresh .. " ",        desc = "Load Last Session", key = "S", action = function() vim.api.nvim_command("SessionManager load_last_session") end },
                        { icon = icons.misc.extensions .. " ",     desc = "Lazy",              key = "l", action = function() require("lazy").home() end },
                        { icon = icons.misc.close .. " ",          desc = "Quit",              key = "q", action = function() vim.cmd.quitall() end },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        return { string.format("%s Neovim loaded %s plugins %s in %s ms %s", icons.misc.bolt, stats.count, icons.misc.plug, ms, icons.misc.bolt) }
                    end,
                },
                hide = {
                    statusline = false,
                    tabline = false,
                    winbar = true,
                },
            }

            vim.api.nvim_set_hl(0, "DashboardHeader", { link = colors.yellow })
            for _, button in ipairs(opts.config.center) do
                button.desc = button.desc .. string.rep(" ", 48 - #button.desc)
                button.icon_hl = colors.purple
                button.key_hl = colors.red
                button.key_format = " %s"
            end
            vim.api.nvim_set_hl(0, "DashboardFooter", { link = colors.blue })

            return opts
        end,
    },
}
