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
                    end, "Prev Hunk")

                    -- Actions
                    map("n", "<leader>gs", gitsigns.stage_hunk, "Stage Hunk")
                    map("n", "<leader>gr", gitsigns.reset_hunk, "Reset Hunk")

                    map("x", "<leader>gs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
                    map("x", "<leader>gr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")

                    map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
                    map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
                    map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
                    map("n", "<leader>gi", gitsigns.preview_hunk_inline, "Preview hunk inline")

                    map("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end, "Blame line")

                    map("n", "<leader>gd", gitsigns.diffthis, "Diff this")

                    map("n", "<leader>gD", function() gitsigns.diffthis("~") end, "Diff this ~")

                    map("n", "<leader>gQ", function() gitsigns.setqflist("all") end, "Set qf all")
                    map("n", "<leader>gq", gitsigns.setqflist, "Set qf")

                    map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, "Toggle current line blame")
                    map("n", "<leader>gtd", gitsigns.toggle_deleted, "Toggle deleted")
                    map("n", "<leader>gtw", gitsigns.toggle_word_diff, "Toggle word diff")

                    -- Text object
                    map({ "x", "o" }, "ih", gitsigns.select_hunk, "Select hunk")
                end,
            }
        end,
    },

    {
        "spacedentist/resolve.nvim",
        cmd = {
            "ResolveNext",
            "ResolvePrev",
            "ResolveOurs",
            "ResolveTheirs",
            "ResolveBoth",
            "ResolveBothReverse",
            "ResolveBase",
            "ResolveNone",
            "ResolveList",
            "ResolveDetect",
            "ResolveDiffOurs",
            "ResolveDiffTheirs",
            "ResolveDiffBoth",
            "ResolveDiffOursTheirs",
            "ResolveDiffTheirsOurs",
        },
        cond = not environment.is_vscode,
        event = {
            "User GitFile",
        },
        opts = {
            -- Set to false to disable default keymaps
            default_keymaps = false,
            -- Callback function called when conflicts are detected
            -- Receives: { bufnr = number, conflicts = table }
            on_conflict_detected = function(info)
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = info.bufnr, desc = desc, silent = true })
                end

                if require("utils").is_available("which-key.nvim") then
                    require("which-key").add(
                        { "<leader>gc", buffer = info.bufnr, group = "git conflicts", mode = "n" },
                        { "<leader>gcd", buffer = info.bufnr, group = "git diff", mode = "n" }
                    )
                end
                map("n", "]x", "<Plug>(resolve-next)", "Next conflict")
                map("n", "[x", "<Plug>(resolve-prev)", "Previous conflict")
                map("n", "<leader>gco", "<Plug>(resolve-ours)", "Choose ours")
                map("n", "<leader>gct", "<Plug>(resolve-theirs)", "Choose theirs")
                map("n", "<leader>gcb", "<Plug>(resolve-both)", "Choose both")
                map("n", "<leader>gcB", "<Plug>(resolve-both-reverse)", "Choose both reverse")
                map("n", "<leader>gcm", "<Plug>(resolve-base)", "Choose base")
                map("n", "<leader>gcn", "<Plug>(resolve-none)", "Choose none")
                map("n", "<leader>gcdo", "<Plug>(resolve-diff-ours)", "Diff ours")
                map("n", "<leader>gcdt", "<Plug>(resolve-diff-theirs)", "Diff theirs")
                map("n", "<leader>gcdb", "<Plug>(resolve-diff-both)", "Diff both")
                map("n", "<leader>gcdv", "<Plug>(resolve-diff-vs)", "Diff ours → theirs")
                map("n", "<leader>gcdV", "<Plug>(resolve-diff-vs-reverse)", "Diff theirs → ours")
                map("n", "<leader>gcl", "<Plug>(resolve-list)", "List conflicts")
            end,
        },
    },
}
