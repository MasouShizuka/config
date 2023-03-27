local variables = require("variables")

local plugin_list = {
    {
        "echasnovski/mini.nvim",
        config = function()
            require("plugin_config.mini")
        end,
        version = false,
    },

    {
        "gbprod/cutlass.nvim",
        config = function()
            require("plugin_config.cutlass")
        end,
    },

    {
        "gbprod/substitute.nvim",
        config = function()
            require("plugin_config.substitute")
        end,
    },

    {
        "gbprod/yanky.nvim",
        config = function()
            require("plugin_config.yanky")
        end,
    },

    {
        "karb94/neoscroll.nvim",
        config = function()
            require("plugin_config.neoscroll")
        end,
    },

    {
        "kevinhwang91/nvim-hlslens",
        config = function()
            require("plugin_config.nvim-hlslens")
        end,
    },

    {
        "monaqa/dial.nvim",
        config = function()
            require("plugin_config.dial")
        end,
    },

    {
        "otavioschwanck/cool-substitute.nvim",
        config = function()
            require("plugin_config.cool-substitute")
        end,
    },

    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function()
            require("plugin_config.hop")
        end,
    },
}

if variables.is_windows then
    local plugin_windows = {
        {
            "keaising/im-select.nvim",
            config = function()
                require("plugin_config.im_select")
            end,
        },
    }

    for index, value in ipairs(plugin_windows) do
        table.insert(plugin_list, value)
    end
end

if not variables.is_vscode then
    local plugin_terminal = {
        {
            "akinsho/bufferline.nvim",
            config = function()
                require("plugin_config.bufferline")
            end,
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
            version = "v3.*",
        },

        {
            "ekickx/clipboard-image.nvim",
            config = function()
                require("plugin_config.clipboard-image")
            end,
        },

        {
            "iamcco/markdown-preview.nvim",
            build = function() vim.fn["mkdp#util#install"]() end,
        },

        {
            "nvim-lualine/lualine.nvim",
            config = function()
                require("plugin_config.lualine")
            end,
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
        },

        {
            "nvim-tree/nvim-tree.lua",
            config = function()
                require("plugin_config.nvim-tree")
            end,
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
            version = "*",
        },

        {
            "olimorris/onedarkpro.nvim",
            config = function()
                require("plugin_config.onedarkpro")
            end,
        },
    }

    for index, value in ipairs(plugin_terminal) do
        table.insert(plugin_list, value)
    end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup(plugin_list)
