local M = {}

M.setup = function(opts)
    -- Mappings
    vim.keymap.set("n", "<c-s-v>", function() vim.cmd.normal({ [["+p]], bang = true }) end, { silent = true }) -- Paste normal mode
    vim.keymap.set("v", "<c-s-v>", function() vim.cmd.normal({ [["+p]], bang = true }) end, { silent = true }) -- Paste visual mode
    vim.keymap.set("c", "<c-s-v>", "<c-r>+", {})                                                               -- Paste command mode
    vim.keymap.set("i", "<c-s-v>", "<c-r>+", { silent = true })                                                -- Paste insert mode

    local change_scale_factor = function(delta)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
    vim.keymap.set("n", "<c-=>", function() change_scale_factor(1.25) end)
    vim.keymap.set("n", "<c-->", function() change_scale_factor(1 / 1.25) end)
    vim.keymap.set("n", "<c-0>", function() vim.g.neovide_scale_factor = 1.0 end)

    -- Display
    vim.g.neovide_window_blurred = true
    vim.g.neovide_opacity = 0.6
    vim.g.neovide_normal_opacity = 0.6
    vim.g.neovide_underline_stroke_scale = 2.0

    -- Cursor Particles
    vim.g.neovide_cursor_vfx_mode = "railgun"
end

return M
