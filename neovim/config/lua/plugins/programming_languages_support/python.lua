local environment = require("utils.environment")
local path = require("utils.path")

return {
    -- NOTE: 需要安装 fd
    {
        "linux-cultist/venv-selector.nvim",
        branch = "regexp",
        cmd = {
            "VenvSelect",
        },
        config = function(_, opts)
            require("venv-selector").setup(opts)

            -- 设置 python 的 环境切换 keymap
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if ft == "python" then
                        vim.keymap.set("n", "<leader>lv", function() vim.api.nvim_command("VenvSelect") end, { buffer = args.buf, desc = "Open VenvSelector to pick a venv", silent = true })
                    end
                end,
                desc = "Venv selector keymap",
                group = vim.api.nvim_create_augroup("VenvKeymap", { clear = true }),
            })
        end,
        dependencies = {
            {
                "mfussenegger/nvim-dap-python",
                config = function(_, opts)
                    local adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/bin/python"
                    if environment.is_windows then
                        adapter_python_path = path.mason_install_root_path .. "/packages/debugpy/venv/Scripts/python.exe"
                    end
                    require("dap-python").setup(adapter_python_path)
                end,
                dependencies = {
                    "mfussenegger/nvim-dap",
                },
                keys = {
                    { "<leader>dlm", function() require("dap-python").test_method() end, desc = "Debug Method", ft = "python", mode = "n" },
                    { "<leader>dlc", function() require("dap-python").test_class() end,  desc = "Debug Class",  ft = "python", mode = "n" },
                },
            },

            "neovim/nvim-lspconfig",
        },
        enabled = not environment.is_vscode and environment.lsp_enable,
        init = function()
            -- 激活 venv-selector 并读取环境
            local id
            id = vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
                    if ft == "python" then
                        require("lazy").load({ plugins = "venv-selector.nvim" })
                        require("utils").refresh_buf(args.buf, { timeout = 3000, use_timer = false })
                        vim.api.nvim_del_autocmd(id)
                    end
                end,
                desc = "Auto select virtualenv",
            })
        end,
        opts = function()
            local config = {
                settings = {
                    cache = {
                        file = path.data_path .. "/venvs2.json",
                    },
                },
            }

            if environment.is_windows then
                config.settings.search = {
                    anaconda_envs = {
                        command = string.format([[$FD python.exe$ %s --full-path -a -E Lib]], path.conda_path .. "/envs"),
                        type = "anaconda",
                    },
                    anaconda_base = {
                        command = string.format([[$FD python.exe$ %s --full-path -a --color never -d 1]], path.conda_path),
                        type = "anaconda",
                    },
                }
            end

            return config
        end,
    },
}
