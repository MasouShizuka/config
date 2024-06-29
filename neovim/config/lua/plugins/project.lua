local environment = require("utils.environment")

return {
    -- NOTE: 需要安装 ripgrep 和 sed
    {
        "nvim-pack/nvim-spectre",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not environment.is_vscode,
        keys = {
            { "<leader><c-f>", function() require("spectre").open() end, desc = "Search and replace in project", mode = "n" },
        },
        opts = function()
            local config = {
                mapping = {
                    ["toggle_line"] = { map = "d", cmd = "<cmd>lua require('spectre').toggle_line()<cr>", desc = "toggle current item" },
                    ["enter_file"] = { map = "<cr>", cmd = "<cmd>lua require('spectre.actions').select_entry()<cr>", desc = "goto current file" },
                    ["send_to_qf"] = { map = "<leader>q", cmd = "<cmd>lua require('spectre.actions').send_to_qf()<cr>", desc = "send all item to quickfix" },
                    ["replace_cmd"] = { map = "<leader>c", cmd = "<cmd>lua require('spectre.actions').replace_cmd()<cr>", desc = "input replace vim command" },
                    ["show_option_menu"] = { map = "<leader>o", cmd = "<cmd>lua require('spectre').show_options()<cr>", desc = "show option" },
                    ["run_current_replace"] = { map = "r", cmd = "<cmd>lua require('spectre.actions').run_current_replace()<cr>", desc = "replace current line" },
                    ["run_replace"] = { map = "R", cmd = "<cmd>lua require('spectre.actions').run_replace()<cr>", desc = "replace all" },
                    ["change_view_mode"] = { map = "<leader>v", cmd = "<cmd>lua require('spectre').change_view()<cr>", desc = "change result view mode" },
                    ["change_replace_sed"] = { map = "trs", cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<cr>", desc = "use sed to replace" },
                    ["change_replace_oxi"] = { map = "tro", cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<cr>", desc = "use oxi to replace" },
                    ["toggle_live_update"] = { map = "tu", cmd = "<cmd>lua require('spectre').toggle_live_update()<cr>", desc = "update change when vim write file." },
                    ["toggle_ignore_case"] = { map = "ti", cmd = "<cmd>lua require('spectre').change_options('ignore-case')<cr>", desc = "toggle ignore case" },
                    ["toggle_ignore_hidden"] = { map = "th", cmd = "<cmd>lua require('spectre').change_options('hidden')<cr>", desc = "toggle search hidden" },
                    ["resume_last_search"] = { map = "<leader>l", cmd = "<cmd>lua require('spectre').resume_last_search()<cr>", desc = "resume last search before close" },
                },
            }

            if environment.is_windows then
                -- windows 下的 msys2 中的 sed 命令会将 end of line 转换成 \r
                -- 因此需要添加 flag：-b, --binary    open files in binary mode (CR+LFs are not processed specially)
                -- https://github.com/msys2/MSYS2-packages/issues/1950
                -- https://stackoverflow.com/questions/4652652/preserve-line-endings
                config["replace_engine"] = {
                    ["sed"] = {
                        args = {
                            "-i",
                            "-E",
                            "-b",
                        },
                    },
                }
            end

            return config
        end,
    },
}
