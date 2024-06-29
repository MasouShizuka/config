local environment = require("utils.environment")
local icons = require("utils.icons")
local keymap = require("utils.keymap")

return {
    {
        "lewis6991/gitsigns.nvim",
        enabled = not environment.is_vscode,
        event = {
            "User GitFile",
        },
        init = function()
            local is_which_key_available, which_key = pcall(require, "which-key")
            if is_which_key_available then
                which_key.register({
                    mode = "n",
                    ["<leader>g"] = {
                        name = "+gitsigns",
                    },
                })
            end
        end,
        opts = {
            signs = {
                add          = { text = icons.misc.left_half_block },
                change       = { text = icons.misc.left_half_medium_shade },
                delete       = { text = icons.misc.caret_right },
                topdelete    = { text = icons.misc.caret_right },
                changedelete = { text = icons.misc.left_half_medium_shade },
                untracked    = { text = icons.misc.left_half_block },
            },
            signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
            numhl = true,      -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 100,
                ignore_whitespace = false,
            },
            preview_config = {
                -- Options passed to nvim_open_win
                border = "rounded",
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "<c-n>", function()
                    local diff = vim.api.nvim_get_option_value("diff", { scope = "local" })
                    if diff then
                        vim.cmd.normal({ "]c", bang = true })
                        vim.cmd.normal({ "zz", bang = true })
                        return
                    end
                    vim.schedule(function() gs.next_hunk() end)
                end, { desc = "Navigation next", silent = true })
                map("n", keymap["<c-s-n>"], function()
                    local diff = vim.api.nvim_get_option_value("diff", { scope = "local" })
                    if diff then
                        vim.cmd.normal({ "[c", bang = true })
                        vim.cmd.normal({ "zz", bang = true })
                        return
                    end
                    vim.schedule(function() gs.prev_hunk() end)
                end, { desc = "Navigation previous", silent = true })

                -- Actions
                map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk", silent = true })
                map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk", silent = true })
                map("x", "<leader>gs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end, { desc = "Stage hunk", silent = true })
                map("x", "<leader>gr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end, { desc = "Reset hunk", silent = true })
                map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer", silent = true })
                map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk", silent = true })
                map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset hunk", silent = true })
                map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk", silent = true })
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line", silent = true })
                -- map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle current line blame", silent = true })
                map("n", "<leader>gd", gs.diffthis, { desc = "Diffthis", silent = true })
                map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "Diffthis ~", silent = true })
                -- map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted", silent = true })

                -- Text object
                map({ "x", "o" }, "ih", ":<c-u>Gitsigns select_hunk<cr>", { desc = "Select hunk", silent = true })
            end,
        },
    },
}
