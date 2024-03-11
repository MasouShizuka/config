local environment = require("utils.environment")
local path = require("utils.path")
local utils = require("utils")

return {
    -- NOTE: 需要安装 fd
    {
        "linux-cultist/venv-selector.nvim",
        cmd = {
            "VenvSelect",
            "VenvSelectCached",
        },
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim",
            -- "mfussenegger/nvim-dap-python",
        },
        enabled = not environment.is_vscode,
        init = function()
            -- 激活 venv-selector 并读取环境
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    if vim.bo[args.buf].filetype == "python" then
                        utils.defer(function() require("venv-selector").retrieve_from_cache() end, 2000, false)
                        vim.api.nvim_del_augroup_by_name("VenvActivate")
                    end
                end,
                desc = "Auto select virtualenv",
                group = vim.api.nvim_create_augroup("VenvActivate", { clear = true }),
            })

            -- 设置 python 的 环境切换 keymap
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    if vim.bo[args.buf].filetype == "python" then
                        vim.keymap.set("n", "<leader>lv", function() require("venv-selector").open() end, { buffer = args.buf, desc = "Open VenvSelector to pick a venv", silent = true })
                    end
                end,
                desc = "Venv selector keymap",
                group = vim.api.nvim_create_augroup("VenvKeymap", { clear = true }),
            })
        end,
        opts = {
            anaconda_base_path = path.conda_path,
            anaconda_envs_path = path.conda_path .. "/envs",
            anaconda = {
                python_parent_dir = "",
            },
            cache_file = path.data_path .. "/lazy/venv-selector.nvim/venv-selector/venvs.json",
            cache_dir = path.data_path .. "/lazy/venv-selector.nvim/venv-selector",
        },
    },
}
