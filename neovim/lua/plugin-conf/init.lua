local global = require("global")

require("plugin-conf/cool-substitute")
require("plugin-conf/hop")
require("plugin-conf/nvim-hlslens")
require("plugin-conf/nvim-surround")
require("plugin-conf/substitute")
require("plugin-conf/vim-textobj-pastedtext")

if global.is_windows then
    require("plugin-conf/vim-im-select")
end

if not global.is_vscode then
    require("plugin-conf/bufferline")
    require("plugin-conf/clipboard-image")
    require("plugin-conf/Comment")
    require("plugin-conf/indent-blankline")
    require("plugin-conf/lualine")
    require("plugin-conf/nvim-autopairs")
    require("plugin-conf/nvim-tree")
end
