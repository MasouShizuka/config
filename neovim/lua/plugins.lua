local global = require("global")

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
        install_path })
    vim.cmd [[packadd packer.nvim]]
end

return require("packer").startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"



    use {
        "phaazon/hop.nvim",
        branch = "v2",
    }

    use "kevinhwang91/nvim-hlslens"

    use "kylechui/nvim-surround"

    use "gbprod/substitute.nvim"

    use "junegunn/vim-easy-align"

    use {
        "mg979/vim-visual-multi",
        branch = "master",
    }

    if global.is_windows then
        use "brglng/vim-im-select"
    end

    if not global.is_vscode then
        use {
            "akinsho/bufferline.nvim",
            tag = "v2.*",
            requires = "kyazdani42/nvim-web-devicons",
        }

        use "ekickx/clipboard-image.nvim"

        use "numToStr/Comment.nvim"

        use "lukas-reineke/indent-blankline.nvim"

        use {
            "nvim-lualine/lualine.nvim",
            requires = {
                "kyazdani42/nvim-web-devicons",
                opt = true
            },
        }

        use {
            "iamcco/markdown-preview.nvim",
            run = function() vim.fn["mkdp#util#install"]() end,
        }

        use "windwp/nvim-autopairs"

        use {
            "kyazdani42/nvim-tree.lua",
            requires = {
                "kyazdani42/nvim-web-devicons",
            },
            tag = "nightly",
        }

        use "olimorris/onedarkpro.nvim"
    end



    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)
