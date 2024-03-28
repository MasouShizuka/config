-- NOTE: 当 neovim 正式版 到 v0.10，去掉以下
if vim.fn.has("nvim-0.10") == 0 then
    vim.uv = vim.loop
end

-- 令 plugin_manager 先激活，使得配置中的 utils.is_available 能够生效
require("config.plugin_manager")
require("config.options")
require("config.mappings")
require("config.autocommands")
require("config.user_commands")
