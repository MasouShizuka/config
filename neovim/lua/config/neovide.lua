local variables = require("config.variables")

if variables.is_neovide then
    -- options
    vim.opt.title = true
    vim.opt.titlestring = "neovide"

    -- mappings
    vim.keymap.set("n", "<c-v>", '"+P', { silent = true }) -- Paste normal mode
    vim.keymap.set("v", "<c-v>", '"+P', {})                -- Paste visual mode
    vim.keymap.set("c", "<c-v>", "<c-r>+", {})             -- Paste command mode
    vim.keymap.set("i", "<c-v>", '<esc>"+pa', {})          -- Paste insert mode

    -- Display
    vim.o.guifont = "Sarasa Mono SC Nerd Font:h15"
    vim.g.neovide_transparency = 0.6

    -- Functionality
    vim.g.neovide_refresh_rate = 60

    -- Input Settings
    vim.g.neovide_input_ime = true

    -- Cursor Settings
    vim.g.neovide_cursor_animation_length = 0.05
    vim.g.neovide_cursor_trail_size = 0.5

    -- Cursor Particles
    vim.g.neovide_cursor_vfx_mode = "railgun"
end
