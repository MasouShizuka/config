local global = require("global")

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"


    use "otavioschwanck/cool-substitute.nvim"

    use {
        "phaazon/hop.nvim",
        branch = "v2",
    }

    use "karb94/neoscroll.nvim"

    use "kevinhwang91/nvim-hlslens"

    use {
        "kylechui/nvim-surround",
        tag = "*",
    }

    use "gbprod/substitute.nvim"

    use "junegunn/vim-easy-align"

    use {
        "thinca/vim-textobj-between",
        requires = "kana/vim-textobj-user",
    }

    use {
        "D4KU/vim-textobj-chainmember",
        requires = "kana/vim-textobj-user",
    }

    use {
        "Chun-Yang/vim-textobj-chunk",
        requires = "kana/vim-textobj-user",
    }

    use {
        "kana/vim-textobj-entire",
        requires = "kana/vim-textobj-user",
    }

    use {
        "kana/vim-textobj-indent",
        requires = "kana/vim-textobj-user",
    }

    use {
        "sgur/vim-textobj-parameter",
        requires = "kana/vim-textobj-user",
    }

    use {
        "saaguero/vim-textobj-pastedtext",
        requires = "kana/vim-textobj-user",
    }

    use {
        "beloglazov/vim-textobj-quotes",
        requires = "kana/vim-textobj-user",
    }

    use {
        "Julian/vim-textobj-variable-segment",
        requires = "kana/vim-textobj-user",
    }

    use "svban/YankAssassin.vim"

    if global.is_windows then
        use "brglng/vim-im-select"
    end

    if not global.is_vscode then
        use {
            "akinsho/bufferline.nvim",
            tag = "v3.*",
            requires = "nvim-tree/nvim-web-devicons",
        }

        use "ekickx/clipboard-image.nvim"

        use "numToStr/Comment.nvim"

        use "lukas-reineke/indent-blankline.nvim"

        use {
            "nvim-lualine/lualine.nvim",
            requires = {
                "nvim-tree/nvim-web-devicons",
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
                "nvim-tree/nvim-web-devicons",
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
