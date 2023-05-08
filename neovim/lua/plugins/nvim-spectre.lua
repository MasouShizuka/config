local variables = require("variables")

return {
    "nvim-pack/nvim-spectre",
    cond = not variables.is_vscode,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        {
            "<Leader><C-f>",
            function()
                require("spectre").open()
            end,
            mode = "n",
        },
        {
            "<C-f>",
            function()
                require("spectre").open_file_search()
            end,
            mode = "n",
        },
    },
    opts = {
        mapping = {
            ["toggle_line"] = {
                map = "d",
                cmd = "<Cmd>lua require('spectre').toggle_line()<CR>",
                desc = "toggle current item",
            },
            ["enter_file"] = {
                map = "<CR>",
                cmd = "<Cmd>lua require('spectre.actions').select_entry()<CR>",
                desc = "goto current file",
            },
            ["send_to_qf"] = {
                map = "<Leader>q",
                cmd = "<Cmd>lua require('spectre.actions').send_to_qf()<CR>",
                desc = "send all item to quickfix",
            },
            ["replace_cmd"] = {
                map = "<Leader>c",
                cmd = "<Cmd>lua require('spectre.actions').replace_cmd()<CR>",
                desc = "input replace vim command",
            },
            ["show_option_menu"] = {
                map = "<Leader>o",
                cmd = "<Cmd>lua require('spectre').show_options()<CR>",
                desc = "show option",
            },
            ["run_current_replace"] = {
                map = "r",
                cmd = "<Cmd>lua require('spectre.actions').run_current_replace()<CR>",
                desc = "replace current line",
            },
            ["run_replace"] = {
                map = "R",
                cmd = "<Cmd>lua require('spectre.actions').run_replace()<CR>",
                desc = "replace all",
            },
            ["change_view_mode"] = {
                map = "<Leader>v",
                cmd = "<Cmd>lua require('spectre').change_view()<CR>",
                desc = "change result view mode",
            },
            ["change_replace_sed"] = {
                map = "trs",
                cmd = "<Cmd>lua require('spectre').change_engine_replace('sed')<CR>",
                desc = "use sed to replace",
            },
            ["change_replace_oxi"] = {
                map = "tro",
                cmd = "<Cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
                desc = "use oxi to replace",
            },
            ["toggle_live_update"] = {
                map = "tu",
                cmd = "<Cmd>lua require('spectre').toggle_live_update()<CR>",
                desc = "update change when vim write file.",
            },
            ["toggle_ignore_case"] = {
                map = "ti",
                cmd = "<Cmd>lua require('spectre').change_options('ignore-case')<CR>",
                desc = "toggle ignore case",
            },
            ["toggle_ignore_hidden"] = {
                map = "th",
                cmd = "<Cmd>lua require('spectre').change_options('hidden')<CR>",
                desc = "toggle search hidden",
            },
            ["resume_last_search"] = {
                map = "<Leader>l",
                cmd = "<Cmd>lua require('spectre').resume_last_search()<CR>",
                desc = "resume last search before close",
            },
        },
    },
}
