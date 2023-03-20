local global = require("global")

local plugin_list = {
    {
        "otavioschwanck/cool-substitute.nvim",
        config = function()
            require("plugin_config.cool-substitute")
        end,
    },

    {
        "echasnovski/mini.nvim",
        config = function()
            require("plugin_config.mini")
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
    }
}

if global.is_windows then
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

if not global.is_vscode then
    local plugin_terminal = {
        {
            "akinsho/bufferline.nvim",
            config = function()
                require("plugin_config.bufferline")
            end,
            dependencies = "nvim-tree/nvim-web-devicons",
            version = "v3.*",
        },

        {
            "ekickx/clipboard-image.nvim",
            config = function()
                require("plugin_config.clipboard-image")
            end,
        },

        {
            "nvim-lualine/lualine.nvim",
            config = function()
                require("plugin_config.lualine")
            end,
            dependencies = {
                {
                    "nvim-tree/nvim-web-devicons",
                    lazy = true,
                },
            },
        },

        {
            "iamcco/markdown-preview.nvim",
            build = function() vim.fn["mkdp#util#install"]() end,
        },

        {
            "kyazdani42/nvim-tree.lua",
            config = function()
                require("plugin_config.nvim-tree")
            end,
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
            version = "nightly",
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
