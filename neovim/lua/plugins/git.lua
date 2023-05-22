local variables = require("config.variables")

return {
    {
        "lewis6991/gitsigns.nvim",
        cond = function()
            local cmd = "git -C \"" .. vim.fn.expand("%:p:h") .. '" rev-parse'
            local wind32_cmd
            if variables.is_windows then
                wind32_cmd = { "cmd.exe", "/C", cmd }
            end
            local result = vim.fn.system(wind32_cmd or cmd)
            local success = vim.api.nvim_get_vvar("shell_error") == 0
            if success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil then
                return true
            end

            return false
        end,
        enabled = not variables.is_vscode,
        event = {
            "BufReadPost",
            "BufNewFile",
        },
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.register({
                    mode = "n",
                    ["<leader>g"] = {
                        name = "+gitsigns",
                    },
                })
            end
        end,
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
            numhl = true,      -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                interval = 1000,
                follow_files = true,
            },
            attach_to_untracked = true,
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 100,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil,  -- Use default
            max_file_length = 40000, -- Disable if file is longer than this (in lines)
            preview_config = {
                -- Options passed to nvim_open_win
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
            yadm = {
                enable = false,
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
                    if vim.wo.diff then
                        vim.cmd.normal("]c")
                        vim.cmd.normal("zz")
                        return
                    end
                    vim.schedule(function() gs.next_hunk() end)
                end, { desc = "Navigation next", silent = true })

                map("n", variables.keymap["<c-s-n>"], function()
                    if vim.wo.diff then
                        vim.cmd.normal("[c")
                        vim.cmd.normal("zz")
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
                -- map({ "o", "x" }, "ih", ":<c-U>Gitsigns select_hunk<cr>", { desc = "Select hunk", silent = true })
            end,
        },
    },

    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewToggleFiles",
            "DiffviewFocusFiles",
            "DiffviewRefresh",
        },
        config = function(_, opts)
            local actions = require("diffview.actions")

            require("diffview").setup({
                file_panel = {
                    win_config = {
                        position = "left",
                        width = 35,
                        win_opts = {},
                    },
                },
                file_history_panel = {
                    win_config = {
                        position = "left",
                        width = 35,
                        win_opts = {},
                    },
                },
                keymaps = {
                    disable_defaults = true,
                    view = {
                        { "n", "<tab>",       actions.select_next_entry,             { desc = "Open the diff for the next file" } },
                        { "n", "<s-tab>",     actions.select_prev_entry,             { desc = "Open the diff for the previous file" } },
                        { "n", "gf",          actions.goto_file_edit,                { desc = "Open the file in the previous tabpage" } },
                        { "n", "<c-w><c-f>",  actions.goto_file_split,               { desc = "Open the file in a new split" } },
                        { "n", "<c-w>gf",     actions.goto_file_tab,                 { desc = "Open the file in a new tabpage" } },
                        -- { "n", "<leader>e",   actions.focus_files,                   { desc = "Bring focus to the file panel" } },
                        -- { "n", "<leader>b",   actions.toggle_files,                  { desc = "Toggle the file panel." } },
                        { "n", "<leader>ve",  actions.focus_files,                   { desc = "Bring focus to the file panel" } },
                        { "n", "<leader>vb",  actions.toggle_files,                  { desc = "Toggle the file panel." } },
                        { "n", "g<c-x>",      actions.cycle_layout,                  { desc = "Cycle through available layouts." } },
                        -- { "n", "[x",          actions.prev_conflict,                 { desc = "In the merge-tool: jump to the previous conflict" } },
                        -- { "n", "]x",          actions.next_conflict,                 { desc = "In the merge-tool: jump to the next conflict" } },
                        -- { "n", "<leader>co",  actions.conflict_choose("ours"),       { desc = "Choose the OURS version of a conflict" } },
                        -- { "n", "<leader>ct",  actions.conflict_choose("theirs"),     { desc = "Choose the THEIRS version of a conflict" } },
                        -- { "n", "<leader>cb",  actions.conflict_choose("base"),       { desc = "Choose the BASE version of a conflict" } },
                        -- { "n", "<leader>ca",  actions.conflict_choose("all"),        { desc = "Choose all the versions of a conflict" } },
                        { "n", "<leader>vco", actions.conflict_choose("ours"),       { desc = "Choose the OURS version of a conflict" } },
                        { "n", "<leader>vct", actions.conflict_choose("theirs"),     { desc = "Choose the THEIRS version of a conflict" } },
                        { "n", "<leader>vcb", actions.conflict_choose("base"),       { desc = "Choose the BASE version of a conflict" } },
                        { "n", "<leader>vca", actions.conflict_choose("all"),        { desc = "Choose all the versions of a conflict" } },
                        { "n", "dx",          actions.conflict_choose("none"),       { desc = "Delete the conflict region" } },
                        -- { "n", "<leader>cO",  actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
                        -- { "n", "<leader>cT",  actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
                        -- { "n", "<leader>cB",  actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
                        -- { "n", "<leader>cA",  actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
                        { "n", "<leader>vcO", actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
                        { "n", "<leader>vcT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
                        { "n", "<leader>vcB", actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
                        { "n", "<leader>vcA", actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
                        { "n", "dX",          actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
                    },
                    diff1 = {
                        -- Mappings in single window diff layouts
                        -- { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
                        { "n", "?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
                    },
                    diff2 = {
                        -- Mappings in 2-way diff layouts
                        -- { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
                        { "n", "?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
                    },
                    diff3 = {
                        -- Mappings in 3-way diff layouts
                        { { "n", "x" }, "2do", actions.diffget("ours"),           { desc = "Obtain the diff hunk from the OURS version of the file" } },
                        { { "n", "x" }, "3do", actions.diffget("theirs"),         { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
                        -- { "n",          "g?",  actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
                        { "n",          "?",   actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
                    },
                    diff4 = {
                        -- Mappings in 4-way diff layouts
                        { { "n", "x" }, "1do", actions.diffget("base"),           { desc = "Obtain the diff hunk from the BASE version of the file" } },
                        { { "n", "x" }, "2do", actions.diffget("ours"),           { desc = "Obtain the diff hunk from the OURS version of the file" } },
                        { { "n", "x" }, "3do", actions.diffget("theirs"),         { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
                        -- { "n",          "g?",  actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
                        { "n",          "?",   actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
                    },
                    file_panel = {
                        { "n", "j",             actions.next_entry,                    { desc = "Bring the cursor to the next file entry" } },
                        { "n", "J",             actions.select_next_entry,             { desc = "Select next entry" } },
                        { "n", "<down>",        actions.next_entry,                    { desc = "Bring the cursor to the next file entry" } },
                        { "n", "k",             actions.prev_entry,                    { desc = "Bring the cursor to the previous file entry" } },
                        { "n", "K",             actions.select_prev_entry,             { desc = "Select previous entry" } },
                        { "n", "<up>",          actions.prev_entry,                    { desc = "Bring the cursor to the previous file entry" } },
                        -- { "n", "<cr>",          actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                        { "n", "o",             actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                        { "n", "l",             actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                        { "n", "<2-LeftMouse>", actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                        { "n", "-",             actions.toggle_stage_entry,            { desc = "Stage / unstage the selected entry" } },
                        { "n", "S",             actions.stage_all,                     { desc = "Stage all entries" } },
                        { "n", "U",             actions.unstage_all,                   { desc = "Unstage all entries" } },
                        { "n", "X",             actions.restore_entry,                 { desc = "Restore entry to the state on the left side" } },
                        { "n", "L",             actions.open_commit_log,               { desc = "Open the commit log panel" } },
                        { "n", "zo",            actions.open_fold,                     { desc = "Expand fold" } },
                        { "n", "h",             actions.close_fold,                    { desc = "Collapse fold" } },
                        { "n", "zc",            actions.close_fold,                    { desc = "Collapse fold" } },
                        { "n", "za",            actions.toggle_fold,                   { desc = "Toggle fold" } },
                        { "n", "zR",            actions.open_all_folds,                { desc = "Expand all folds" } },
                        { "n", "zM",            actions.close_all_folds,               { desc = "Collapse all folds" } },
                        -- { "n", "<c-b>",         actions.scroll_view(-0.25),            { desc = "Scroll the view up" } },
                        -- { "n", "<c-f>",         actions.scroll_view(0.25),             { desc = "Scroll the view down" } },
                        { "n", "<c-u>",         actions.scroll_view(-0.25),            { desc = "Scroll the view up" } },
                        { "n", "<c-d>",         actions.scroll_view(0.25),             { desc = "Scroll the view down" } },
                        { "n", "<tab>",         actions.select_next_entry,             { desc = "Open the diff for the next file" } },
                        { "n", "<s-tab>",       actions.select_prev_entry,             { desc = "Open the diff for the previous file" } },
                        { "n", "gf",            actions.goto_file_edit,                { desc = "Open the file in the previous tabpage" } },
                        { "n", "<cr>",          actions.goto_file_edit,                { desc = "Open the file in the previous tabpage" } },
                        { "n", "<c-w><c-f>",    actions.goto_file_split,               { desc = "Open the file in a new split" } },
                        { "n", "<c-w>gf",       actions.goto_file_tab,                 { desc = "Open the file in a new tabpage" } },
                        { "n", "t",             actions.goto_file_tab,                 { desc = "Open the file in a new tabpage" } },
                        { "n", "i",             actions.listing_style,                 { desc = "Toggle between 'list' and 'tree' views" } },
                        { "n", "f",             actions.toggle_flatten_dirs,           { desc = "Flatten empty subdirectories in tree listing style" } },
                        { "n", "R",             actions.refresh_files,                 { desc = "Update stats and entries in the file list" } },
                        -- { "n", "<leader>e",     actions.focus_files,                   { desc = "Bring focus to the file panel" } },
                        -- { "n", "<leader>b",     actions.toggle_files,                  { desc = "Toggle the file panel" } },
                        { "n", "<leader>ve",    actions.focus_files,                   { desc = "Bring focus to the file panel" } },
                        { "n", "<leader>vb",    actions.toggle_files,                  { desc = "Toggle the file panel" } },
                        { "n", "g<c-x>",        actions.cycle_layout,                  { desc = "Cycle available layouts" } },
                        { "n", "c",             actions.cycle_layout,                  { desc = "Cycle available layouts" } },
                        -- { "n", "[x",            actions.prev_conflict,                 { desc = "Go to the previous conflict" } },
                        -- { "n", "]x",            actions.next_conflict,                 { desc = "Go to the next conflict" } },
                        -- { "n", "g?",            actions.help("file_panel"),            { desc = "Open the help panel" } },
                        { "n", "?",             actions.help("file_panel"),            { desc = "Open the help panel" } },
                        -- { "n", "<leader>cO",    actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
                        -- { "n", "<leader>cT",    actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
                        -- { "n", "<leader>cB",    actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
                        -- { "n", "<leader>cA",    actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
                        { "n", "<leader>vcO",   actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
                        { "n", "<leader>vcT",   actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
                        { "n", "<leader>vcB",   actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
                        { "n", "<leader>vcA",   actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
                        { "n", "dX",            actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
                    },
                    file_history_panel = {
                        { "n", "g!",            actions.options,                    { desc = "Open the option panel" } },
                        -- { "n", "<c-A-d>",       actions.open_in_diffview,           { desc = "Open the entry under the cursor in a diffview" } },
                        { "n", "y",             actions.copy_hash,                  { desc = "Copy the commit hash of the entry under the cursor" } },
                        { "n", "L",             actions.open_commit_log,            { desc = "Show commit details" } },
                        { "n", "zR",            actions.open_all_folds,             { desc = "Expand all folds" } },
                        { "n", "zM",            actions.close_all_folds,            { desc = "Collapse all folds" } },
                        { "n", "j",             actions.next_entry,                 { desc = "Bring the cursor to the next file entry" } },
                        { "n", "J",             actions.select_next_entry,          { desc = "Select next entry" } },
                        { "n", "<down>",        actions.next_entry,                 { desc = "Bring the cursor to the next file entry" } },
                        { "n", "k",             actions.prev_entry,                 { desc = "Bring the cursor to the previous file entry." } },
                        { "n", "K",             actions.select_prev_entry,          { desc = "Select previous entry" } },
                        { "n", "<up>",          actions.prev_entry,                 { desc = "Bring the cursor to the previous file entry." } },
                        { "n", "<cr>",          actions.open_in_diffview,           { desc = "Open the diff for the selected entry." } },
                        { "n", "o",             actions.select_entry,               { desc = "Open the diff for the selected entry." } },
                        { "n", "l",             actions.select_entry,               { desc = "Open the diff for the selected entry." } },
                        { "n", "<2-LeftMouse>", actions.select_entry,               { desc = "Open the diff for the selected entry." } },
                        -- { "n", "<c-b>",         actions.scroll_view(-0.25),         { desc = "Scroll the view up" } },
                        -- { "n", "<c-f>",         actions.scroll_view(0.25),          { desc = "Scroll the view down" } },
                        { "n", "<c-u>",         actions.scroll_view(-0.25),         { desc = "Scroll the view up" } },
                        { "n", "<c-d>",         actions.scroll_view(0.25),          { desc = "Scroll the view down" } },
                        { "n", "<tab>",         actions.select_next_entry,          { desc = "Open the diff for the next file" } },
                        { "n", "<s-tab>",       actions.select_prev_entry,          { desc = "Open the diff for the previous file" } },
                        { "n", "gf",            actions.goto_file_edit,             { desc = "Open the file in the previous tabpage" } },
                        { "n", "<c-w><c-f>",    actions.goto_file_split,            { desc = "Open the file in a new split" } },
                        { "n", "<c-w>gf",       actions.goto_file_tab,              { desc = "Open the file in a new tabpage" } },
                        { "n", "t",             actions.goto_file_tab,              { desc = "Open the file in a new tabpage" } },
                        -- { "n", "<leader>e",     actions.focus_files,                { desc = "Bring focus to the file panel" } },
                        -- { "n", "<leader>b",     actions.toggle_files,               { desc = "Toggle the file panel" } },
                        { "n", "<leader>ve",    actions.focus_files,                { desc = "Bring focus to the file panel" } },
                        { "n", "<leader>vb",    actions.toggle_files,               { desc = "Toggle the file panel" } },
                        { "n", "g<c-x>",        actions.cycle_layout,               { desc = "Cycle available layouts" } },
                        { "n", "c",             actions.cycle_layout,               { desc = "Cycle available layouts" } },
                        -- { "n", "g?",            actions.help("file_history_panel"), { desc = "Open the help panel" } },
                        { "n", "?",             actions.help("file_history_panel"), { desc = "Open the help panel" } },
                    },
                    option_panel = {
                        { "n", "<tab>", actions.select_entry,         { desc = "Change the current option" } },
                        { "n", "q",     actions.close,                { desc = "Close the panel" } },
                        -- { "n", "g?",    actions.help("option_panel"), { desc = "Open the help panel" } },
                        { "n", "?",     actions.help("option_panel"), { desc = "Open the help panel" } },
                    },
                    help_panel = {
                        { "n", "q",     actions.close, { desc = "Close help menu" } },
                        { "n", "<esc>", actions.close, { desc = "Close help menu" } },
                    },
                },
            })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        enabled = not variables.is_vscode,
        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.register({
                    mode = "n",
                    ["<leader>v"] = {
                        name = "+diffview",
                    },
                })
            end
        end,
        keys = {
            { "<leader>vv", function() vim.api.nvim_command("DiffviewOpen") end,        desc = "Open",         mode = "n" },
            { "<leader>vf", function() vim.api.nvim_command("DiffviewFileHistory") end, desc = "File history", mode = "n" },
            { "<leader>vq", function() vim.api.nvim_command("DiffviewClose") end,       desc = "Close",        mode = "n" },
            { "<leader>vt", function() vim.api.nvim_command("DiffviewToggleFiles") end, desc = "Toggle files", mode = "n" },
            -- { "<leader>vf", function() vim.api.nvim_command("DiffviewFocusFiles") end,  desc = "Focus files",  mode = "n" },
            { "<leader>vr", function() vim.api.nvim_command("DiffviewRefresh") end,     desc = "Refresh",      mode = "n" },
            { "<leader>vl", function() vim.api.nvim_command("DiffviewLog") end,         desc = "Log",          mode = "n" },
        },
    },
}
