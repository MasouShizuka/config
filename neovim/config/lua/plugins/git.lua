local environment = require("utils.environment")

return {
    {
        "lewis6991/gitsigns.nvim",
        enabled = not environment.is_vscode,
        event = {
            "User GitFile",
        },
        init = function()
            local utils = require("utils")
            if utils.is_available("which-key.nvim") then
                utils.create_once_autocmd("User", {
                    callback = function()
                        require("which-key").add({
                            { "<leader>g", group = "gitsigns", mode = "n" },
                        })
                    end,
                    desc = "Register which-key for gitsigns",
                    pattern = "IceLoad",
                })
            end
        end,
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

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    if require("utils").is_available("which-key.nvim") then
                        require("which-key").add(
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
                    end, { desc = "Next Hunk", silent = true })
                    map("n", require("utils.keymap")["<c-s-n>"], function()
                        local diff = vim.api.nvim_get_option_value("diff", { scope = "local" })
                        if diff then
                            vim.cmd.normal({ "[c", bang = true })
                            vim.cmd.normal({ "zz", bang = true })
                            return
                        end
                        gitsigns.nav_hunk("prev")
                    end, { desc = "Prev Hunk", silent = true })

                    -- Actions
                    map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk", silent = true })
                    map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk", silent = true })

                    map("x", "<leader>gs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk", silent = true })
                    map("x", "<leader>gr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk", silent = true })

                    map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer", silent = true })
                    map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk", silent = true })
                    map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset hunk", silent = true })
                    map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk", silent = true })
                    map("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline", silent = true })

                    map("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end, { desc = "Blame line", silent = true })

                    map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff this", silent = true })

                    map("n", "<leader>gD", function() gitsigns.diffthis("~") end, { desc = "Diff this ~", silent = true })

                    map("n", "<leader>gQ", function() gitsigns.setqflist("all") end, { desc = "Set qf all", silent = true })
                    map("n", "<leader>gq", gitsigns.setqflist, { desc = "Set qf", silent = true })

                    map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame", silent = true })
                    map("n", "<leader>gtd", gitsigns.toggle_deleted, { desc = "Toggle deleted", silent = true })
                    map("n", "<leader>gtw", gitsigns.toggle_word_diff, { desc = "Toggle word diff", silent = true })

                    -- Text object
                    map({ "x", "o" }, "ih", gitsigns.select_hunk, { desc = "Select hunk", silent = true })
                end,
            }
        end,
    },
}
