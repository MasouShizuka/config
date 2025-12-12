local environment = require("utils.environment")

return {
    {
        "lewis6991/gitsigns.nvim",
        cond = not environment.is_vscode,
        event = {
            "User GitFile",
        },
        opts = function()
            local icons = require("utils.icons")

            return {
                signs = {
                    add          = { text = icons.misc.left_half_block },
                    change       = { text = icons.misc.left_half_medium_shade },
                    delete       = { text = icons.misc.caret_right },
                    topdelete    = { text = icons.misc.caret_right },
                    changedelete = { text = icons.misc.left_half_medium_shade },
                    untracked    = { text = icons.misc.left_half_block },
                },
                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                    delay = 100,
                },
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = "rounded",
                },
                on_attach = function(bufnr)
                    local gitsigns = package.loaded.gitsigns

                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
                    end

                    if require("utils").is_available("which-key.nvim") then
                        require("which-key").add(
                            { "<leader>g", buffer = bufnr, group = "gitsigns", mode = "n" },
                            { "<leader>gt", buffer = bufnr, group = "gitsigns toggle", mode = "n" }
                        )
                    end

                    -- Navigation
                    map("n", "<c-n>", function()
                        local diff = vim.api.nvim_get_option_value("diff", { scope = "local" })
                        if diff then
                            vim.cmd.normal({ "]c", bang = true })
                            vim.cmd.normal({ "zz", bang = true })
                            return
                        end
                        gitsigns.nav_hunk("next")
                    end, "Next Hunk")
                    map("n", require("utils.keymap")["<c-s-n>"], function()
                        local diff = vim.api.nvim_get_option_value("diff", { scope = "local" })
                        if diff then
                            vim.cmd.normal({ "[c", bang = true })
                            vim.cmd.normal({ "zz", bang = true })
                            return
                        end
                        gitsigns.nav_hunk("prev")
                    end, "Next Hunk")

                    -- Actions
                    map("n", "<leader>gs", gitsigns.stage_hunk, "Next Hunk")
                    map("n", "<leader>gr", gitsigns.reset_hunk, "Next Hunk")

                    map("x", "<leader>gs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Next Hunk")
                    map("x", "<leader>gr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Next Hunk")

                    map("n", "<leader>gS", gitsigns.stage_buffer, "Next Hunk")
                    map("n", "<leader>gR", gitsigns.reset_buffer, "Next Hunk")
                    map("n", "<leader>gp", gitsigns.preview_hunk, "Next Hunk")
                    map("n", "<leader>gi", gitsigns.preview_hunk_inline, "Next Hunk")

                    map("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end, "Next Hunk")

                    map("n", "<leader>gd", gitsigns.diffthis, "Next Hunk")

                    map("n", "<leader>gD", function() gitsigns.diffthis("~") end, "Next Hunk")

                    map("n", "<leader>gQ", function() gitsigns.setqflist("all") end, "Next Hunk")
                    map("n", "<leader>gq", gitsigns.setqflist, "Next Hunk")

                    map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, "Next Hunk")
                    map("n", "<leader>gtd", gitsigns.toggle_deleted, "Next Hunk")
                    map("n", "<leader>gtw", gitsigns.toggle_word_diff, "Next Hunk")

                    -- Text object
                    map({ "x", "o" }, "ih", gitsigns.select_hunk, "Next Hunk")
                end,
            }
        end,
    },
}
